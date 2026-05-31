import { describe, expect, it, vi } from 'vitest'
import { shareCurrentPage } from './share-current-page'

describe('shareCurrentPage', () => {
  it('uses native sharing when available', () => {
    const share = vi.fn()
    const writeText = vi.fn()
    const alert = vi.fn()

    shareCurrentPage({
      title: 'Family book',
      text: 'Read this memory book',
      url: 'https://example.test/share/book',
      copiedMessage: 'Copied',
      navigatorRef: {
        share,
        clipboard: { writeText },
      },
      alertRef: alert,
    })

    expect(share).toHaveBeenCalledWith({
      title: 'Family book',
      text: 'Read this memory book',
      url: 'https://example.test/share/book',
    })
    expect(writeText).not.toHaveBeenCalled()
    expect(alert).not.toHaveBeenCalled()
  })

  it('copies the current URL when native sharing is unavailable', () => {
    const writeText = vi.fn()
    const alert = vi.fn()

    shareCurrentPage({
      title: 'Family book',
      text: 'Read this memory book',
      url: 'https://example.test/share/book',
      copiedMessage: 'Copied',
      navigatorRef: {
        clipboard: { writeText },
      },
      alertRef: alert,
    })

    expect(writeText).toHaveBeenCalledWith('https://example.test/share/book')
    expect(alert).toHaveBeenCalledWith('Copied')
  })
})
