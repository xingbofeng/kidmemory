import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

import { HealthController } from '../../../../src/modules/health/health.controller.ts';

describe('HealthController', () => {
  it('returns cloud-api health metadata with an ISO timestamp', () => {
    const response = new HealthController().getHealth();

    assert.equal(response.status, 'ok');
    assert.equal(response.service, 'cloud-api');
    assert.equal(response.version, '1.0.0');
    assert.doesNotThrow(() => new Date(response.timestamp).toISOString());
  });

  it('returns readiness metadata with an ISO timestamp', () => {
    const response = new HealthController().getReadiness();

    assert.equal(response.status, 'ready');
    assert.doesNotThrow(() => new Date(response.timestamp).toISOString());
  });
});
