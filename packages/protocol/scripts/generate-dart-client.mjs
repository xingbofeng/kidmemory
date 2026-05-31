#!/usr/bin/env node

import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
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
  rmSync(target.output, { recursive: true, force: true })
  mkdirSync(dirname(target.output), { recursive: true })
  const result = useLocal ? runLocalGenerator(target.input, target.output) : runDockerGenerator(target.input, target.output)
  if (result.status !== 0) {
    process.exit(result.status ?? 1)
  }
  rmSync(join(target.output, 'test'), { recursive: true, force: true })
  removeRemovedSidecarBookArtifacts(target)
  exportGeneratedModels(target.output)
  normalizeGeneratedPubspec(target.output)
  stripGeneratedTrailingWhitespace(target.output)
  console.log(`Generated Dart client: ${target.output}`)
}

function removeRemovedSidecarBookArtifacts(target) {
  if (!target.input.endsWith('sidecar.openapi.json')) return

  for (const relativePath of [
    'doc/BooksApi.md',
    'doc/BookExportResponseDto.md',
    'doc/CreateBookJobRequestDto.md',
    'doc/CreateBookJobResponseDto.md',
    'doc/ExportBookRequestDto.md',
    'doc/ExportLongImageRequestDto.md',
    'doc/ExportedPayloadResponseDto.md',
    'lib/src/api/books_api.dart',
    'lib/src/model/book_export_response_dto.dart',
    'lib/src/model/book_export_response_dto.g.dart',
    'lib/src/model/create_book_job_request_dto.dart',
    'lib/src/model/create_book_job_request_dto.g.dart',
    'lib/src/model/create_book_job_response_dto.dart',
    'lib/src/model/create_book_job_response_dto.g.dart',
    'lib/src/model/export_book_request_dto.dart',
    'lib/src/model/export_book_request_dto.g.dart',
    'lib/src/model/export_long_image_request_dto.dart',
    'lib/src/model/export_long_image_request_dto.g.dart',
    'lib/src/model/exported_payload_response_dto.dart',
    'lib/src/model/exported_payload_response_dto.g.dart',
    'test/books_api_test.dart',
    'test/book_export_response_dto_test.dart',
    'test/create_book_job_request_dto_test.dart',
    'test/create_book_job_response_dto_test.dart',
    'test/export_book_request_dto_test.dart',
    'test/export_long_image_request_dto_test.dart',
    'test/exported_payload_response_dto_test.dart',
  ]) {
    rmSync(join(target.output, relativePath), { force: true })
  }
}

function exportGeneratedModels(outputDir) {
  const libraryPath = join(outputDir, 'lib', 'kidmemory_protocol.dart')
  const modelDir = join(outputDir, 'lib', 'src', 'model')
  const source = readFileSync(libraryPath, 'utf8')
  const withoutExistingModelExports = source
    .split('\n')
    .filter((line) => !line.includes("src/model/"))
    .join('\n')

  if (!existsSync(modelDir)) {
    writeFileSync(libraryPath, `${withoutExistingModelExports.trimEnd()}\n`)
    return
  }

  const modelExports = readdirSync(modelDir)
    .filter((file) => file.endsWith('.dart') && !file.endsWith('.g.dart'))
    .sort()
    .map((file) => `export 'package:kidmemory_protocol/src/model/${file}';`)
    .join('\n')

  if (!modelExports) return

  writeFileSync(libraryPath, `${withoutExistingModelExports.trimEnd()}\n\n${modelExports}\n`)
}

function normalizeGeneratedPubspec(outputDir) {
  const pubspecPath = join(outputDir, 'pubspec.yaml')
  const source = readFileSync(pubspecPath, 'utf8')
  writeFileSync(
    pubspecPath,
    source.replace(/^  build_runner: any$/m, '  build_runner: ^2.4.15'),
  )
}

function stripGeneratedTrailingWhitespace(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = join(dir, entry.name)
    if (entry.isDirectory()) {
      stripGeneratedTrailingWhitespace(fullPath)
      continue
    }
    if (!entry.isFile() || !isGeneratedTextFile(entry.name)) continue

    const source = readFileSync(fullPath, 'utf8')
    const normalized = source.replace(/[ \t]+$/gm, '').replace(/\n{2,}$/g, '\n')
    if (normalized !== source) {
      writeFileSync(fullPath, normalized)
    }
  }
}

function isGeneratedTextFile(fileName) {
  return /\.(dart|md|yaml|yml|gitignore)$/.test(fileName)
    || fileName === 'VERSION'
    || fileName === 'FILES'
}
