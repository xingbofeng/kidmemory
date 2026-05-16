#!/usr/bin/env node

import { mkdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { spawnSync } from 'node:child_process'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const root = join(__dirname, '..')

const targets = [
  {
    input: join(root, 'openapi', 'sidecar.openapi.json'),
    output: join(root, 'generated', 'sidecar', 'dart'),
  },
  {
    input: join(root, 'openapi', 'cloud-api.openapi.json'),
    output: join(root, 'generated', 'cloud-api', 'dart'),
  },
]

function hasCommand(command, args = ['--version']) {
  const result = spawnSync(command, args, { stdio: 'ignore' })
  return result.status === 0
}

function hasDockerDaemon() {
  if (!hasCommand('docker')) return false
  const result = spawnSync('docker', ['info'], { stdio: 'ignore' })
  return result.status === 0
}

function resolveJavaBin() {
  if (hasCommand('java')) return 'java'
  const homebrewJava = '/opt/homebrew/opt/openjdk/bin/java'
  return hasCommand(homebrewJava, ['-version']) ? homebrewJava : null
}

function hasWorkingJava() {
  const javaBin = resolveJavaBin()
  if (!javaBin) return false
  const result = spawnSync(javaBin, ['-version'], { encoding: 'utf8' })
  if (result.status !== 0) return false
  const output = `${result.stdout ?? ''}\n${result.stderr ?? ''}`
  return !output.includes('Unable to locate a Java Runtime')
}

function runLocalGenerator(inputFile, outputDir) {
  const javaBinDir = '/opt/homebrew/opt/openjdk/bin'
  return spawnSync(
    'npx',
    [
      '@openapitools/openapi-generator-cli',
      'generate',
      '-g',
      'dart-dio',
      '-i',
      inputFile,
      '-o',
      outputDir,
      '--additional-properties',
      'pubName=kidmemory_protocol,serializationLibrary=json_serializable',
      '--skip-validate-spec',
    ],
    {
      stdio: 'inherit',
      env: {
        ...process.env,
        PATH: `${javaBinDir}:${process.env.PATH ?? ''}`,
      },
    },
  )
}

function runDockerGenerator(inputFile, outputDir) {
  const containerRoot = '/local/protocol'
  const inputInContainer = inputFile.replace(root, containerRoot)
  const outputInContainer = outputDir.replace(root, containerRoot)

  return spawnSync(
    'docker',
    [
      'run',
      '--rm',
      '-v',
      `${root}:${containerRoot}`,
      'openapitools/openapi-generator-cli:v7.22.0',
      'generate',
      '-g',
      'dart-dio',
      '-i',
      inputInContainer,
      '-o',
      outputInContainer,
      '--additional-properties',
      'pubName=kidmemory_protocol,serializationLibrary=json_serializable',
      '--skip-validate-spec',
    ],
    { stdio: 'inherit' },
  )
}

const useDocker = hasDockerDaemon()
const useLocal = !useDocker && hasWorkingJava()

if (!useLocal && !useDocker) {
  console.error('Neither Java nor Docker is available; cannot generate Dart clients.')
  process.exit(1)
}

for (const target of targets) {
  mkdirSync(dirname(target.output), { recursive: true })
  const result = useLocal ? runLocalGenerator(target.input, target.output) : runDockerGenerator(target.input, target.output)
  if (result.status !== 0) {
    process.exit(result.status ?? 1)
  }
  console.log(`Generated Dart client: ${target.output}`)
}
