#!/usr/bin/env node

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import openapiTS, { astToString } from 'openapi-typescript'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const root = join(__dirname, '..')

const targets = [
  {
    input: join(root, 'openapi', 'cloud-api.openapi.json'),
    output: join(root, 'generated', 'cloud-api', 'ts', 'index.d.ts'),
  },
  {
    input: join(root, 'openapi', 'sidecar.openapi.json'),
    output: join(root, 'generated', 'sidecar', 'ts', 'index.d.ts'),
  },
]

for (const target of targets) {
  const schema = JSON.parse(readFileSync(target.input, 'utf8'))
  const ast = await openapiTS(schema)
  const output = astToString(ast)

  mkdirSync(dirname(target.output), { recursive: true })
  writeFileSync(target.output, output)
  console.log(`Generated TS client: ${target.output}`)
}
