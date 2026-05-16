#!/usr/bin/env node

/**
 * Protocol 完整性检查脚本
 *
 * 检查项：
 * 1. 错误码无重复
 * 2. 所有错误码都有中英文文案
 * 3. 文案文件中的错误码都在 ApiCode 中定义
 */

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

// 读取错误码定义
const apiCodePath = join(rootDir, 'src/common/api-code.ts');
const apiCodeContent = readFileSync(apiCodePath, 'utf-8');

// 提取所有错误码
const codeMatches = apiCodeContent.matchAll(/^\s*(\w+)\s*=\s*(\d+),?\s*$/gm);
const codes = new Map();
for (const match of codeMatches) {
  const [, name, value] = match;
  const code = parseInt(value, 10);
  if (codes.has(code)) {
    console.error(`❌ 错误码重复: ${code} (${codes.get(code)} 和 ${name})`);
    process.exit(1);
  }
  codes.set(code, name);
}

console.log(`✓ 检查错误码无重复: ${codes.size} 个错误码`);

// 读取中英文文案
const zhCNPath = join(rootDir, 'errors/messages.zh-CN.json');
const enUSPath = join(rootDir, 'errors/messages.en-US.json');

const zhCNMessages = JSON.parse(readFileSync(zhCNPath, 'utf-8'));
const enUSMessages = JSON.parse(readFileSync(enUSPath, 'utf-8'));

// 检查所有错误码都有文案
let missingMessages = false;
for (const [code, name] of codes) {
  const codeStr = String(code);
  if (!zhCNMessages[codeStr]) {
    console.error(`❌ 缺少中文文案: ${code} (${name})`);
    missingMessages = true;
  }
  if (!enUSMessages[codeStr]) {
    console.error(`❌ 缺少英文文案: ${code} (${name})`);
    missingMessages = true;
  }
}

if (missingMessages) {
  process.exit(1);
}

console.log(`✓ 检查文案完整性: 所有错误码都有中英文文案`);

// 检查文案文件中的错误码都在 ApiCode 中定义
let extraMessages = false;
for (const codeStr of Object.keys(zhCNMessages)) {
  const code = parseInt(codeStr, 10);
  if (!codes.has(code)) {
    console.error(`❌ zh-CN 文案中存在未定义的错误码: ${code}`);
    extraMessages = true;
  }
}

for (const codeStr of Object.keys(enUSMessages)) {
  const code = parseInt(codeStr, 10);
  if (!codes.has(code)) {
    console.error(`❌ en-US 文案中存在未定义的错误码: ${code}`);
    extraMessages = true;
  }
}

if (extraMessages) {
  process.exit(1);
}

console.log(`✓ 检查文案一致性: 文案文件中无多余错误码`);

// 检查中英文文案的错误码数量一致
const zhCNCount = Object.keys(zhCNMessages).length;
const enUSCount = Object.keys(enUSMessages).length;

if (zhCNCount !== enUSCount) {
  console.error(`❌ 中英文文案数量不一致: zh-CN=${zhCNCount}, en-US=${enUSCount}`);
  process.exit(1);
}

console.log(`✓ 检查文案数量一致: ${zhCNCount} 条`);

console.log('\n✅ Protocol 完整性检查通过');
