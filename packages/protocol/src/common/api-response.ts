/**
 * 统一 API 响应结构
 *
 * @template T - 响应数据类型
 */
export interface ApiResponse<T = unknown> {
  /**
   * 错误码，0 表示成功，非 0 表示失败
   */
  code: number;

  /**
   * 响应消息，成功时为 "success"，失败时为错误描述
   */
  msg: string;

  /**
   * 响应数据，成功时包含实际数据，失败时可能为 null 或错误详情
   */
  data: T;
}

/**
 * 分页数据结构
 *
 * @template T - 列表项类型
 */
export interface PageData<T = unknown> {
  /**
   * 当前页的数据列表
   */
  items: T[];

  /**
   * 当前页码（从 1 开始）
   */
  page: number;

  /**
   * 每页大小
   */
  pageSize: number;

  /**
   * 总记录数
   */
  total: number;
}
