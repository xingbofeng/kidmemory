import { http, HttpResponse } from 'msw'

export const handlers = [
  // 0.5 Upload Session API
  http.post('/api/web-companion/sessions', () => {
    return HttpResponse.json({
      sessionId: 'test-session-123',
      token: 'test-token-456',
      expiresAt: new Date(Date.now() + 3 * 60 * 60 * 1000).toISOString(), // 3 hours
      childId: 'child-123',
      childName: '小明',
      maxUploads: 200,
    })
  }),

  http.get('/api/web-companion/sessions/:sessionId', ({ params }) => {
    const sessionId = params.sessionId as string

    // Handle invalid session
    if (sessionId === 'invalid-session') {
      return new HttpResponse(null, { status: 404 })
    }

    // Handle different upload count scenarios for testing
    let uploadCount = 5
    if (sessionId.includes('near-limit')) {
      uploadCount = 195
    } else if (sessionId.includes('at-limit')) {
      uploadCount = 200
    }

    return HttpResponse.json({
      sessionId: params.sessionId,
      isValid: true,
      expiresAt: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
      childId: 'child-123',
      childName: '小明',
      uploadCount,
      maxUploads: 200,
    })
  }),

  // Direct Upload config API
  http.get('/api/web-companion/direct-upload/sessions/:sessionId/config', () => {
    return HttpResponse.json({
      anonKey: 'anon-public-key',
    })
  }),

  // Upload API
  http.post('/api/web-companion/upload', () => {
    return HttpResponse.json({
      uploadId: 'upload-123',
      objectKey: 'uploads/child-123/2024/05/image-123.jpg',
      status: 'pending',
    })
  }),

  // Recent Uploads API
  http.get('/api/web-companion/recent-uploads', () => {
    return HttpResponse.json({
      uploads: [
        {
          id: 'upload-1',
          filename: 'drawing-1.jpg',
          thumbnail: '/api/thumbnails/upload-1',
          type: 'drawing',
          uploadedAt: new Date().toISOString(),
          status: 'ready',
        },
        {
          id: 'upload-2',
          filename: 'photo-1.jpg',
          thumbnail: '/api/thumbnails/upload-2',
          type: 'photo',
          uploadedAt: new Date().toISOString(),
          status: 'pulling_local',
        },
      ],
    })
  }),

  // Assets API
  http.get('/api/web-companion/assets', () => {
    return HttpResponse.json({
      assets: [
        {
          id: 'asset-1',
          title: '我的画作',
          thumbnail: '/api/thumbnails/asset-1',
          type: 'drawing',
          createdAt: new Date().toISOString(),
        },
        {
          id: 'asset-2',
          title: '生日照片',
          thumbnail: '/api/thumbnails/asset-2',
          type: 'photo',
          createdAt: new Date().toISOString(),
        },
      ],
      total: 2,
    })
  }),

  // Books API
  http.get('/api/web-companion/books', () => {
    return HttpResponse.json({
      books: [
        {
          id: 'book-1',
          title: '小明的成长记录',
          cover: '/api/thumbnails/book-1-cover',
          pageCount: 12,
          createdAt: new Date().toISOString(),
          status: 'ready',
          pdfUrl: '/api/books/book-1/pdf',
          longImageUrl: '/api/books/book-1/long-image',
        },
      ],
    })
  }),

  // Share API
  http.get('/api/web-companion/books/:bookId/share', ({ params }) => {
    return HttpResponse.json({
      bookId: params.bookId,
      shareUrl: `https://example.com/share/book-${params.bookId}`,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24 hours
      isPublic: false,
    })
  }),
]
