import { existsSync, readFileSync } from 'node:fs'
import { describe, expect, it } from 'vitest'

describe('share date formatting', () => {
  it('is shared by share surfaces instead of duplicated inside components', () => {
    const helperPath = 'src/utils/shareDate.ts'
    const consumers = [
      'src/components/share/BookShowcase.tsx',
      'src/components/share-browse/AssetsGrid.tsx',
    ]

    expect(existsSync(helperPath)).toBe(true)
    expect(readFileSync(helperPath, 'utf8')).toContain('export function formatShareDate')
    for (const file of consumers) {
      const source = readFileSync(file, 'utf8')
      expect(source).toContain('formatShareDate')
      expect(source).not.toContain('const formatDate =')
      expect(source).not.toContain('toLocaleDateString')
    }
  })
})
