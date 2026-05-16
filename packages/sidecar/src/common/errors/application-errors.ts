/**
 * Application Error Types
 *
 * Standardized error types for the application layer.
 * These errors can be mapped to appropriate HTTP status codes in the presentation layer.
 */

export class ApplicationError extends Error {
  public readonly code: string;
  public readonly statusCode: number;

  constructor(
    message: string,
    code: string,
    statusCode: number = 500,
  ) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
    this.name = this.constructor.name;
  }
}

export class ValidationError extends ApplicationError {
  public readonly field?: string;

  constructor(message: string, field?: string) {
    super(message, 'VALIDATION_ERROR', 400);
    this.field = field;
  }
}

export class NotFoundError extends ApplicationError {
  constructor(resource: string, identifier?: string) {
    const message = identifier
      ? `${resource} with identifier '${identifier}' not found`
      : `${resource} not found`;
    super(message, 'NOT_FOUND', 404);
  }
}

export class ConflictError extends ApplicationError {
  constructor(message: string) {
    super(message, 'CONFLICT', 409);
  }
}

export class UnauthorizedError extends ApplicationError {
  constructor(message: string = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401);
  }
}

export class ForbiddenError extends ApplicationError {
  constructor(message: string = 'Forbidden') {
    super(message, 'FORBIDDEN', 403);
  }
}

export class ServiceUnavailableError extends ApplicationError {
  constructor(message: string) {
    super(message, 'SERVICE_UNAVAILABLE', 503);
  }
}

export class InternalServerError extends ApplicationError {
  constructor(message: string = 'Internal server error') {
    super(message, 'INTERNAL_ERROR', 500);
  }
}

// Domain-specific errors
export class EncryptionNotAvailableError extends ServiceUnavailableError {
  constructor() {
    super('Encryption not available. Cannot perform operation.');
  }
}

export class ConfigurationNotFoundError extends NotFoundError {
  constructor(configId?: string) {
    super('Agent configuration', configId);
  }
}

export class DefaultConfigurationError extends ApplicationError {
  constructor(message: string) {
    super(message, 'DEFAULT_CONFIG_ERROR', 400);
  }
}

export class ApiKeyError extends ApplicationError {
  constructor(message: string) {
    super(message, 'API_KEY_ERROR', 400);
  }
}

export class DecryptionError extends InternalServerError {
  constructor(message: string = 'Failed to decrypt sensitive data') {
    super(message);
  }
}
