import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { DEFAULT_LOCALE, SUPPORTED_LOCALES, type Locale } from '@kidmemory/protocol';

const SUPPORTED_LOCALE_SET = new Set<Locale>(SUPPORTED_LOCALES);

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

    const languages = acceptLanguage
      .split(',')
      .map((lang) => {
        const [locale, qValue] = lang.trim().split(';');
        const quality = qValue ? parseFloat(qValue.split('=')[1]) : 1.0;
        return { locale: locale.trim(), quality };
      })
      .sort((a, b) => b.quality - a.quality);

    for (const { locale } of languages) {
      if (SUPPORTED_LOCALE_SET.has(locale as Locale)) {
        return locale as Locale;
      }
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

export function createLocaleMiddleware() {
  return new LocaleMiddleware();
}
