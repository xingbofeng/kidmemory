import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

export type Locale = 'zh-CN' | 'en-US';
type MessageMap = Record<string, string>;

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function loadMessages(locale: string): MessageMap {
  const filePath = join(
    __dirname,
    '../../../../protocol/errors',
    `messages.${locale}.json`,
  );
  return JSON.parse(readFileSync(filePath, 'utf-8')) as MessageMap;
}

const messages: Record<Locale, MessageMap> = {
  'zh-CN': loadMessages('zh-CN'),
  'en-US': loadMessages('en-US'),
};

export class MessageService {
  getMessage(code: number, locale: Locale = 'zh-CN'): string {
    const messageMap = messages[locale] ?? messages['zh-CN'];
    return messageMap[code.toString()] ?? messageMap['10000'] ?? '未知错误';
  }
}

export const messageService = new MessageService();
