import { describe, it, expect } from 'vitest'
import { filterAssets, getAssetTypeLabel, getFilterLabel } from './assetUtils'
import { Asset } from '../types/asset'

describe('assetUtils', () => {
  const mockAssets: Asset[] = [
    {
      id: '1',
      name: '我的画作',
      type: 'drawing',
      thumbnailUrl: '/drawing.jpg',
      createdAt: '2024-01-15'
    },
    {
      id: '2',
      name: '生日照片',
      type: 'photo',
      thumbnailUrl: '/photo.jpg',
      createdAt: '2024-01-14'
    },
    {
      id: '3',
      name: '家庭视频',
      type: 'video',
      thumbnailUrl: '/video.jpg',
      createdAt: '2024-01-13'
    }
  ]

  describe('filterAssets', () => {
    it('returns all assets when filter is "all"', () => {
      const result = filterAssets(mockAssets, 'all', '')
      expect(result).toEqual(mockAssets)
    })

    it('filters assets by type', () => {
      const result = filterAssets(mockAssets, 'drawing', '')
      expect(result).toHaveLength(1)
      expect(result[0].type).toBe('drawing')
    })

    it('filters assets by search query', () => {
      const result = filterAssets(mockAssets, 'all', '画作')
      expect(result).toHaveLength(1)
      expect(result[0].name).toBe('我的画作')
    })

    it('filters assets by both type and search query', () => {
      const result = filterAssets(mockAssets, 'photo', '生日')
      expect(result).toHaveLength(1)
      expect(result[0].name).toBe('生日照片')
    })

    it('returns empty array when no matches found', () => {
      const result = filterAssets(mockAssets, 'drawing', '不存在')
      expect(result).toHaveLength(0)
    })

    it('handles case insensitive search', () => {
      const result = filterAssets(mockAssets, 'all', '画作')
      expect(result).toHaveLength(1)
      expect(result[0].name).toBe('我的画作')
    })

    it('trims search query whitespace', () => {
      const result = filterAssets(mockAssets, 'all', '  画作  ')
      expect(result).toHaveLength(1)
      expect(result[0].name).toBe('我的画作')
    })
  })

  describe('getAssetTypeLabel', () => {
    it('returns correct labels for asset types', () => {
      expect(getAssetTypeLabel('drawing')).toBe('绘画')
      expect(getAssetTypeLabel('photo')).toBe('照片')
      expect(getAssetTypeLabel('video')).toBe('视频')
    })
  })

  describe('getFilterLabel', () => {
    it('returns correct labels for filters', () => {
      expect(getFilterLabel('all')).toBe('全部')
      expect(getFilterLabel('drawing')).toBe('绘画')
      expect(getFilterLabel('photo')).toBe('照片')
      expect(getFilterLabel('video')).toBe('视频')
    })
  })
})