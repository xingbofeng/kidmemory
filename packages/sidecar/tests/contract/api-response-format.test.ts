/**
 * Contract Tests for API Response Format
 *
 * Verifies unified API response format:
 * - All responses use: { code, msg, data }
 * - Success: code = 0
 * - Errors: code > 0
 */

import { describe, it } from 'node:test';
import assert from 'node:assert';

describe('API Response Format Contract Tests', () => {
  const BASE_URL = process.env.TEST_API_URL || 'http://localhost:4317';

  describe('Success Responses', () => {
    it('should return unified format for successful requests', async () => {
      const response = await fetch(`${BASE_URL}/api/health`);
      const data = await response.json();

      // Unified format structure
      assert.ok('code' in data, 'Should have code field');
      assert.ok('msg' in data, 'Should have msg field');
      assert.ok('data' in data, 'Should have data field');

      // Success code should be 0
      assert.strictEqual(data.code, 0, 'Success code should be 0');
      assert.strictEqual(data.msg, 'success', 'Success message should be "success"');
    });
  });

  describe('Error Responses', () => {
    it('should return unified format for 404 errors', async () => {
      const response = await fetch(`${BASE_URL}/api/nonexistent`);
      const data = await response.json();

      // Unified format error
      assert.strictEqual(response.status, 404);
      assert.ok('code' in data, 'Should have code field');
      assert.ok('msg' in data, 'Should have msg field');
      assert.ok('data' in data, 'Should have data field');

      // Error code should be non-zero
      assert.notStrictEqual(data.code, 0, 'Error code should be non-zero');
      assert.ok(data.code >= 10000, 'Error code should be in valid range');
    });
  });

  describe('Validation Errors', () => {
    it('should return unified format for validation errors', async () => {
      const response = await fetch(`${BASE_URL}/api/web-companion/sessions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({}), // Missing required childId
      });
      const data = await response.json();

      assert.strictEqual(response.status, 400);
      assert.ok('code' in data, 'Should have code field');
      assert.ok('msg' in data, 'Should have msg field');
      assert.ok('data' in data, 'Should have data field');
      assert.notStrictEqual(data.code, 0, 'Error code should be non-zero');
    });
  });

  describe('Rate Limit Errors', () => {
    it('should return unified format for rate limit errors', async () => {
      // Make many requests to trigger rate limit
      const requests = Array.from({ length: 150 }, () =>
        fetch(`${BASE_URL}/api/health`)
      );

      const responses = await Promise.all(requests);
      const rateLimitResponse = responses.find(r => r.status === 429);

      if (rateLimitResponse) {
        const data = await rateLimitResponse.json();

        assert.ok('code' in data, 'Should have code field');
        assert.ok('msg' in data, 'Should have msg field');
        assert.ok('data' in data, 'Should have data field');
        assert.ok(data.code === 16001 || data.code === 16002, 'Should be rate limit error code');
      }
    });
  });

  describe('File Stream Responses', () => {
    it('should not wrap file streams in API format', async () => {
      // This test assumes there's a file download endpoint
      // Skip if endpoint doesn't exist
      const response = await fetch(`${BASE_URL}/api/books/test-book-id/download`);
      
      if (response.status === 404) {
        // Endpoint doesn't exist, skip test
        return;
      }

      const contentType = response.headers.get('content-type');
      
      // File streams should not be JSON
      if (contentType?.includes('application/json')) {
        const data = await response.json();
        // If it's JSON, it should be an error in unified format
        assert.ok('code' in data, 'JSON response should be in unified format');
        assert.ok('msg' in data, 'JSON response should be in unified format');
        assert.ok('data' in data, 'JSON response should be in unified format');
      } else {
        // Should be binary data
        assert.ok(
          contentType?.includes('application/octet-stream') || 
          contentType?.includes('application/pdf'),
          'Should be binary content type'
        );
      }
    });
  });
});
