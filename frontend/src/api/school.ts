import apiClient from './client'
import type { 
  School, 
  SchoolSetting, 
  SchoolApplication, 
  SchoolStatistics 
} from '@/types/school'

export const schoolApi = {
  // 申請新學校
  async applySchool(application: SchoolApplication): Promise<School> {
    return apiClient.post('/api/schools/apply', { school: application })
  },

  // 獲取學校資訊
  async getSchool(schoolId: number): Promise<School> {
    return apiClient.get(`/api/admin/schools/${schoolId}`)
  },

  // 更新學校資訊
  async updateSchool(schoolId: number, data: Partial<School>): Promise<School> {
    return apiClient.patch(`/api/schools/${schoolId}`, data)
  },

  // 獲取學校設定
  async getSchoolSettings(schoolId: number): Promise<SchoolSetting> {
    return apiClient.get(`/api/schools/${schoolId}/setting`)
  },

  // 更新學校設定
  async updateSchoolSettings(schoolId: number, settings: Partial<SchoolSetting>): Promise<SchoolSetting> {
    return apiClient.patch(`/api/schools/${schoolId}/setting`, settings)
  },

  // 創建學校設定
  async createSchoolSettings(schoolId: number, settings: Partial<SchoolSetting>): Promise<SchoolSetting> {
    return apiClient.post(`/api/schools/${schoolId}/setting`, settings)
  },

  // 獲取學校統計資料
  async getSchoolStatistics(schoolId: number): Promise<SchoolStatistics> {
    return apiClient.get(`/api/schools/${schoolId}/statistics`)
  },

  // 管理員專用 - 獲取待審核學校
  async getPendingSchools(): Promise<School[]> {
    return apiClient.get('/api/admin/schools/pending')
  },

  // 管理員專用 - 核准學校
  async approveSchool(schoolId: number): Promise<School> {
    return apiClient.post(`/api/admin/schools/${schoolId}/approve`)
  },

  // 管理員專用 - 拒絕學校申請
  async rejectSchool(schoolId: number, reason?: string): Promise<School> {
    return apiClient.post(`/api/admin/schools/${schoolId}/reject`, { reason })
  },

  // 管理員專用 - 獲取所有學校
  async getAllSchools(): Promise<School[]> {
    return apiClient.get('/api/admin/schools')
  }
}