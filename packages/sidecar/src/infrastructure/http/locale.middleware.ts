import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

export type Locale = 'zh-CN' | 'en-US';

const SUPPORTED_LOCALES: Locale[] = ['zh-CN', 'en-US'];
const DEFAULT_LOCALE: Locale = 'zh-CN';

declare global {
  namespace Express {
    interface Request {
      locale?: Locale;
    }
  }
}

export class LocaleMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const acceptLanguage = req.headers['accept-language'];
    req.locale = this.parseLocale(acceptLanguage);
    next();
  }

  private parseLocale(acceptLanguage: string | undefined): Locale {
    if (!acceptLanguage) {
      return DEFAULT_LOCALE;
    }

    // 解析 Accept-Language header
    // 格式: "zh-CN,zh;q=0.9,en;q=0.8"
    const languages = acceptLanguage
      .split(',')
      .map((lang) => {
        const [locale, qValue] = lang.trim().split(';');
        const quality = qValue ? parseFloat(qValue.split('=')[1]) : 1.0;
        return { locale: locale.trim(), quality };
      })
      .sort((a, b) => b.quality - a.quality);

    // 查找第一个支持的语言
    for (const { locale } of languages) {
      // 精确匹配
      if (SUPPORTED_LOCALES.includes(locale as Locale)) {
        return locale as Locale;
      }
      // 语言前缀匹配 (zh -> zh-CN)
      const prefix = locale.split('-')[0];
      const matched = SUPPORTED_LOCALES.find((supported) =>
        supported.startsWith(prefix),
      );
      if (matched) {
        return matched;
      }
    }

    return DEFAULT_LOCALE;
  }
}

// 导出工厂函数供 NestJS 使用
export function createLocaleMiddleware() {
  return new LocaleMiddleware();
}
