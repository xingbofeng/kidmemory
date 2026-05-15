# Sidecar Modules

The sidecar is arranged with the standard NestJS module shape:

- `config/config.module.ts`, `config/config.controller.ts`, and `config/config.service.ts` own health, config status, readiness, and schema routes.
- `config/providers/` keeps readiness orchestration and local config helpers close to the config feature.
- `dataset/dataset.module.ts`, `dataset/dataset.controller.ts`, `dataset/dataset.service.ts`, `dataset/dto/`, and `dataset/providers/` own sample import, children, and assets routes.
- `books/books.module.ts`, `books/books.controller.ts`, `books/books.service.ts`, `books/dto/`, and `books/providers/` own generation jobs, preview, PDF export, Agent workspace, and book rendering helpers.
- `../infrastructure/infrastructure.module.ts` owns shared runtime providers exported to feature modules.
- `../infrastructure/config/`, `../infrastructure/database/`, `../infrastructure/jobs/`, and `../infrastructure/dataset-state/` expose explicit shared providers for local config, PostgreSQL, job storage, and active dataset state.

`main.ts` and `app.module.ts` are the production NestJS bootstrap path. There is no separate lightweight HTTP runner in production source.

## Nest decorator convention

This project runs TypeScript in strip-only mode, so constructor parameter decorators cannot use normal `@Inject()` syntax. Services should register dependencies with `registerInjectable(ServiceClass, [DependencyA, DependencyB])` from `../infrastructure/nest/register-injectable.ts` instead of repeating inline `Inject(...)(ServiceClass, undefined, index)` calls.

Controllers may still apply route decorators manually after the class declaration because method decorators are part of the public HTTP contract. Keep controllers thin and route declarations grouped at the bottom of each controller file.
