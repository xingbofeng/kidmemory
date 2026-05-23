import 'package:flutter_test/flutter_test.dart';

import 'package:kidmemory_desktop/core/sidecar/sidecar_launcher.dart';

void main() {
  test('keeps startup DATABASE_URL when it is already provided', () {
    final env = buildSidecarLaunchEnvironment(
      platformEnv: {
        'DATABASE_URL': 'postgresql://user:pass@db.example:5432/kidmemory',
        'POSTGRES_HOST': 'ignored-host',
        'POSTGRES_PORT': '5432',
        'POSTGRES_DATABASE': 'ignored-db',
        'POSTGRES_USER': 'ignored-user',
      },
      extraEnvironment: {
        'POSTGRES_HOST': '127.0.0.1',
        'POSTGRES_PORT': '4317',
        'POSTGRES_DATABASE': 'kidmemory',
        'POSTGRES_USER': 'postgres',
      },
    );

    expect(
      env['DATABASE_URL'],
      'postgresql://user:pass@db.example:5432/kidmemory',
    );
    expect(env['POSTGRES_URL'], isNull);
    expect(env['KIDMEMORY_SIDECAR_HOST'], '127.0.0.1');
    expect(env['KIDMEMORY_SIDECAR_PORT'], '4317');
  });

  test('derives DATABASE_URL from POSTGRES_* when no url is provided', () {
    final env = buildSidecarLaunchEnvironment(
      platformEnv: const {},
      extraEnvironment: {
        'POSTGRES_HOST': 'db.local',
        'POSTGRES_PORT': '15432',
        'POSTGRES_DATABASE': 'kidmemory_test',
        'POSTGRES_USER': 'kid',
        'POSTGRES_PASSWORD': 'secret password',
      },
    );

    expect(
      env['DATABASE_URL'],
      'postgresql://kid:secret%20password@db.local:15432/kidmemory_test',
    );
    expect(
      env['POSTGRES_URL'],
      'postgresql://kid:secret%20password@db.local:15432/kidmemory_test',
    );
  });
}
