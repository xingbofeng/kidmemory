import { strict as assert } from "node:assert";

export type ContractResponse<T = unknown> = {
  status: number;
  headers: Headers;
  body: T;
  rawBody: string;
};

export async function requestJson<T = unknown>(
  baseUrl: string,
  path: string,
  init: RequestInit = {},
): Promise<ContractResponse<T>> {
  const response = await fetch(`${baseUrl}${path}`, {
    ...init,
    headers: {
      ...(init.body === undefined ? {} : { "content-type": "application/json" }),
      ...(init.headers ?? {}),
    },
  });
  const rawBody = await response.text();
  const body = rawBody.length > 0 ? JSON.parse(rawBody) as T : undefined as T;

  return {
    status: response.status,
    headers: response.headers,
    body,
    rawBody,
  };
}

export function assertObject(value: unknown, message = "expected object"): asserts value is Record<string, unknown> {
  assert.equal(typeof value, "object", message);
  assert.notEqual(value, null, message);
}

export function assertString(value: unknown, message = "expected string"): asserts value is string {
  assert.equal(typeof value, "string", message);
}
