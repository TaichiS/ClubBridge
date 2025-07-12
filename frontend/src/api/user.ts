import apiClient from './client'

export interface User {
  id: number
  name: string
  email: string
  user_role: string
  user_role_text: string
  created_at: string
  updated_at: string
  schools: UserSchool[]
}

export interface UserSchool {
  id: number
  name: string
  membership_role: string
  created_at: string
}

export interface UsersResponse {
  users: User[]
  meta: {
    current_page: number
    total_pages: number
    total_count: number
  }
}

export const userApi = {
  // 獲取用戶列表
  async getUsers(page: number = 1, perPage: number = 20): Promise<UsersResponse> {
    return apiClient.get('/api/admin/users', {
      params: { page, per_page: perPage }
    })
  },

  // 獲取單一用戶
  async getUser(userId: number): Promise<User> {
    return apiClient.get(`/api/admin/users/${userId}`)
  },

  // 更新用戶
  async updateUser(userId: number, data: Partial<User>): Promise<User> {
    return apiClient.patch(`/api/admin/users/${userId}`, { user: data })
  },

  // 為用戶添加學校
  async addSchoolToUser(userId: number, schoolId: number, role: string = 'admin'): Promise<User> {
    return apiClient.post(`/api/admin/users/${userId}/add_school`, {
      school_id: schoolId,
      role: role
    })
  },

  // 從用戶移除學校
  async removeSchoolFromUser(userId: number, schoolId: number): Promise<User> {
    return apiClient.delete(`/api/admin/users/${userId}/remove_school`, {
      params: { school_id: schoolId }
    })
  }
}