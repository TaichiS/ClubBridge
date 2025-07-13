import axios, { type AxiosInstance, type AxiosRequestConfig, type AxiosResponse } from 'axios'
import { useAuthStore } from '@/stores/auth'

export interface ApiResponse<T = any> {
  data: T
  message?: string
  status: 'success' | 'error'
}

export interface ApiError {
  message: string
  errors?: Record<string, string[]>
  status: number
}

class ApiClient {
  private client: AxiosInstance

  constructor() {
    this.client = axios.create({
      baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    })

    this.setupInterceptors()
  }

  private setupInterceptors() {
    // 請求攔截器
    this.client.interceptors.request.use(
      (config) => {
        const authStore = useAuthStore()
        
        // 添加認證 token
        if (authStore.token) {
          config.headers.Authorization = `Bearer ${authStore.token}`
        }

        // 添加學校 ID（如果有的話）
        if (authStore.currentSchool) {
          config.headers['X-School-ID'] = authStore.currentSchool.toString()
        }

        return config
      },
      (error) => {
        return Promise.reject(error)
      }
    )

    // 響應攔截器
    this.client.interceptors.response.use(
      (response: AxiosResponse) => {
        return response
      },
      (error) => {
        const authStore = useAuthStore()

        // 處理認證失敗
        if (error.response?.status === 401) {
          authStore.logout()
          // 可以在這裡添加跳轉到登入頁的邏輯
        }

        // 處理伺服器錯誤
        if (error.response?.status >= 500) {
          console.error('Server error:', error.response.data)
        }

        // 格式化錯誤訊息
        const apiError: ApiError = {
          message: error.response?.data?.message || error.message || '發生未知錯誤',
          errors: error.response?.data?.errors,
          status: error.response?.status || 0
        }

        return Promise.reject(apiError)
      }
    )
  }

  // GET 請求
  async get<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.get<T>(url, config)
    return response.data
  }

  // POST 請求
  async post<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.post<T>(url, data, config)
    return response.data
  }

  // PUT 請求
  async put<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.put<T>(url, data, config)
    return response.data
  }

  // PATCH 請求
  async patch<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.patch<T>(url, data, config)
    return response.data
  }

  // DELETE 請求
  async delete<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.delete<T>(url, config)
    return response.data
  }

  // 文件上傳
  async upload<T = any>(url: string, file: File, onProgress?: (progress: number) => void): Promise<T> {
    const formData = new FormData()
    formData.append('file', file)

    const config: AxiosRequestConfig = {
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
          onProgress(progress)
        }
      },
      // 對於匯入功能，422 狀態碼仍包含有用資料，不應拋出錯誤
      validateStatus: (status) => {
        return (status >= 200 && status < 300) || status === 422
      }
    }

    const response = await this.client.post<T>(url, formData, config)
    return response.data
  }

  // 獲取原始 axios 實例（需要時使用）
  getRawClient(): AxiosInstance {
    return this.client
  }
}

// 創建單一實例
export const apiClient = new ApiClient()
export default apiClient