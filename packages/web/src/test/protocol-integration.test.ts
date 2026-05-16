import { describe, it, expect } from 'vitest'
// 任务 1.20: web 引用 ApiResponse 测试
// 使用相对路径引用 protocol 源文件（bundler 模式支持 .ts 扩展名）
import { ApiCode } from '../../../protocol/src/common/api-code.ts'
import type { ApiResponse, PageData } from '../../../protocol/src/common/api-response.ts'

describe('Protocol Integration - Web (任务 1.20)', () => {
  it('可以引用 ApiCode', () => {
    expect(ApiCode.SUCCESS).toBe(0)
    expect(ApiCode.NOT_FOUND).toBe(10001)
    expect(ApiCode.RATE_LIMIT_EXCEEDED).toBe(16001)
  })

  it('可以使用 ApiResponse 类型', () => {
    const response: ApiResponse<{ id: string }> = {
      code: ApiCode.SUCCESS,
      msg: 'success',
      data: { id: '123' },
    }
    expect(response.code).toBe(0)
    expect(response.data.id).toBe('123')
  })

  it('可以使用错误响应', () => {
    const errorResponse: ApiResponse<null> = {
      code: ApiCode.SHARE_TOKEN_EXPIRED,
      msg: '分享 Token 已过期',
      data: null,
    }
    expect(errorResponse.code).toBe(14001)
    expect(errorResponse.data).toBeNull()
  })

  it('可以使用 PageData 类型', () => {
    const page: PageData<{ name: string }> = {
      items: [{ name: '安安' }],
      page: 1,
      pageSize: 20,
      total: 1,
    }
    expect(page.items).toHaveLength(1)
    expect(page.total).toBe(1)
  })
})
