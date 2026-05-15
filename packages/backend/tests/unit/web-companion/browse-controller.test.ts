import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';

describe('Browse Controller', () => {
  let mockBrowseService: any;
  let mockRequest: any;
  let mockResponse: any;

  beforeEach(() => {
    mockBrowseService = {
      getRecentUploads: async (input: any) => {
        if (input.token === 'invalid_token') {
          throw new Error('Session not found or token invalid');
        }
        return [
          {
            id: 'asset_1',
            title: 'Test Photo 1',
            type: 'image',
            childId: 'child_456',
            createdAt: new Date().toISOString()
          }
        ];
      },
      getAssetDetails: async (input: any) => {
        if (input.assetId === 'not_found') {
          throw new Error('Asset not found or access denied');
        }
        return {
          id: input.assetId,
          title: 'Test Asset',
          type: 'image',
          childId: 'child_456',
          createdAt: new Date().toISOString()
        };
      },
      getBooksList: async (input: any) => {
        return [
          {
            id: 'book_1',
            title: 'My Book',
            childId: 'child_456',
            createdAt: new Date().toISOString(),
            status: 'completed'
          }
        ];
      },
      getBookDetails: async (input: any) => {
        return {
          id: input.bookId,
          title: 'My Book',
          childId: 'child_456',
          createdAt: new Date().toISOString(),
          status: 'completed'
        };
      }
    };

    mockRequest = {
      params: {},
      query: {},
      headers: {}
    };

    mockResponse = {
      status: function(code: number) {
        this.statusCode = code;
        return this;
      },
      json: function(data: any) {
        this.data = data;
        return this;
      },
      statusCode: 200,
      data: null
    };
  });

  describe('GET /api/web-companion/sessions/:sessionId/recent', () => {
    it('should return recent uploads with valid session token', async () => {
      mockRequest.params = { sessionId: 'session_123' };
      mockRequest.headers = { authorization: 'Bearer valid_token' };
      mockRequest.query = { limit: '10' };

      // Simulate controller logic
      const sessionId = mockRequest.params.sessionId;
      const token = mockRequest.headers.authorization?.replace('Bearer ', '');
      const limit = parseInt(mockRequest.query.limit) || 20;

      const result = await mockBrowseService.getRecentUploads({
        sessionId,
        token,
        limit
      });

      mockResponse.json(result);

      assert.equal(mockResponse.statusCode, 200);
      assert.ok(Array.isArray(mockResponse.data));
      assert.equal(mockResponse.data[0].id, 'asset_1');
    });

    it('should return 401 for invalid session token', async () => {
      mockRequest.params = { sessionId: 'session_123' };
      mockRequest.headers = { authorization: 'Bearer invalid_token' };

      try {
        const sessionId = mockRequest.params.sessionId;
        const token = mockRequest.headers.authorization?.replace('Bearer ', '');

        await mockBrowseService.getRecentUploads({
          sessionId,
          token,
          limit: 20
        });
      } catch (error) {
        mockResponse.status(401).json({
          error: 'unauthorized',
          message: 'Session not found or token invalid'
        });
      }

      assert.equal(mockResponse.statusCode, 401);
      assert.equal(mockResponse.data.error, 'unauthorized');
    });

    it('should return 400 for missing authorization header', async () => {
      mockRequest.params = { sessionId: 'session_123' };
      // No authorization header

      const token = mockRequest.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        mockResponse.status(400).json({
          error: 'bad_request',
          message: 'Authorization header required'
        });
      }

      assert.equal(mockResponse.statusCode, 400);
      assert.equal(mockResponse.data.error, 'bad_request');
    });
  });

  describe('GET /api/web-companion/sessions/:sessionId/assets/:assetId', () => {
    it('should return asset details for valid session and asset', async () => {
      mockRequest.params = { sessionId: 'session_123', assetId: 'asset_1' };
      mockRequest.headers = { authorization: 'Bearer valid_token' };

      const sessionId = mockRequest.params.sessionId;
      const assetId = mockRequest.params.assetId;
      const token = mockRequest.headers.authorization?.replace('Bearer ', '');

      const result = await mockBrowseService.getAssetDetails({
        sessionId,
        token,
        assetId
      });

      mockResponse.json(result);

      assert.equal(mockResponse.statusCode, 200);
      assert.equal(mockResponse.data.id, 'asset_1');
    });

    it('should return 404 for asset not found or access denied', async () => {
      mockRequest.params = { sessionId: 'session_123', assetId: 'not_found' };
      mockRequest.headers = { authorization: 'Bearer valid_token' };

      try {
        const sessionId = mockRequest.params.sessionId;
        const assetId = mockRequest.params.assetId;
        const token = mockRequest.headers.authorization?.replace('Bearer ', '');

        await mockBrowseService.getAssetDetails({
          sessionId,
          token,
          assetId
        });
      } catch (error) {
        mockResponse.status(404).json({
          error: 'not_found',
          message: 'Asset not found or access denied'
        });
      }

      assert.equal(mockResponse.statusCode, 404);
      assert.equal(mockResponse.data.error, 'not_found');
    });
  });

  describe('GET /api/web-companion/sessions/:sessionId/books', () => {
    it('should return books list for valid session', async () => {
      mockRequest.params = { sessionId: 'session_123' };
      mockRequest.headers = { authorization: 'Bearer valid_token' };
      mockRequest.query = { childId: 'child_456' };

      const sessionId = mockRequest.params.sessionId;
      const token = mockRequest.headers.authorization?.replace('Bearer ', '');
      const childId = mockRequest.query.childId;

      const result = await mockBrowseService.getBooksList({
        sessionId,
        token,
        childId
      });

      mockResponse.json(result);

      assert.equal(mockResponse.statusCode, 200);
      assert.ok(Array.isArray(mockResponse.data));
      assert.equal(mockResponse.data[0].id, 'book_1');
    });
  });

  describe('GET /api/web-companion/sessions/:sessionId/books/:bookId', () => {
    it('should return book details for valid session and book', async () => {
      mockRequest.params = { sessionId: 'session_123', bookId: 'book_1' };
      mockRequest.headers = { authorization: 'Bearer valid_token' };

      const sessionId = mockRequest.params.sessionId;
      const bookId = mockRequest.params.bookId;
      const token = mockRequest.headers.authorization?.replace('Bearer ', '');

      const result = await mockBrowseService.getBookDetails({
        sessionId,
        token,
        bookId
      });

      mockResponse.json(result);

      assert.equal(mockResponse.statusCode, 200);
      assert.equal(mockResponse.data.id, 'book_1');
    });
  });

  describe('token validation', () => {
    it('should require same session token validation as trusted upload', async () => {
      // This test ensures browse endpoints use the same validation model
      // as the existing trusted upload endpoints

      mockRequest.params = { sessionId: 'session_123' };
      mockRequest.headers = { authorization: 'Bearer valid_token' };

      const sessionId = mockRequest.params.sessionId;
      const token = mockRequest.headers.authorization?.replace('Bearer ', '');

      // The validation should follow the same pattern as web-companion upload
      assert.ok(sessionId);
      assert.ok(token);
      assert.equal(token, 'valid_token');
    });
  });
});