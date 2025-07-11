import apiClient from './client'
import type { 
  GoogleAuthResponse, 
  StudentAuthResponse, 
  LoginCredentials,
  User
} from '@/types/auth'

export const authApi = {
  // Google OAuth 登入
  async googleLogin(googleToken: string): Promise<GoogleAuthResponse> {
    return apiClient.post('/api/auth/google', { token: googleToken })
  },

  // 學生登入
  async studentLogin(credentials: LoginCredentials): Promise<StudentAuthResponse> {
    return apiClient.post('/api/auth/student', credentials)
  },

  // 登出
  async logout(): Promise<void> {
    return apiClient.post('/api/auth/logout')
  },

  // 刷新 token
  async refreshToken(): Promise<{ token: string }> {
    return apiClient.post('/api/auth/refresh')
  },

  // 獲取當前使用者資訊
  async getCurrentUser(): Promise<User> {
    return apiClient.get('/api/auth/me')
  },

  // 驗證 token 有效性
  async validateToken(): Promise<{ valid: boolean }> {
    return apiClient.get('/api/auth/validate')
  }
}