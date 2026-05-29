const API_BASE = import.meta.env.VITE_API_BASE || '/api'

interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

type RequestBody = Record<string, unknown> | null | undefined

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: { 'Content-Type': 'application/json', ...(init?.headers || {}) },
    ...init
  })
  const payload = (await response.json()) as ApiResponse<T>
  if (!response.ok || payload.code >= 400) {
    throw new Error(payload.message || '请求失败')
  }
  return payload.data
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body?: RequestBody) =>
    request<T>(path, { method: 'POST', body: body ? JSON.stringify(body) : undefined }),
  put: <T>(path: string, body?: RequestBody) =>
    request<T>(path, { method: 'PUT', body: body ? JSON.stringify(body) : undefined })
}
