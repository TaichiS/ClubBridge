import apiClient from './client'
import type { 
  School, 
  SchoolSetting, 
  SchoolApplication, 
  SchoolStatistics 
} from '@/types/school'

export const schoolApi = {
  // 獲取學校公開資訊
  async getPublicSchool(schoolId: number): Promise<School> {
    return apiClient.get(`/api/public/schools/${schoolId}`)
  },

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
    return apiClient.patch(`/api/admin/schools/${schoolId}`, { school: data })
  },

  // 學校管理員專用 - 獲取學校資訊
  async getSchoolForAdmin(schoolId: number): Promise<School> {
    return apiClient.get(`/api/schools/${schoolId}/admin/school`)
  },

  // 學校管理員專用 - 更新學校資訊
  async updateSchoolForAdmin(schoolId: number, data: Partial<School>): Promise<School> {
    return apiClient.patch(`/api/schools/${schoolId}/admin/school`, { school: data })
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
  },

  // 獲取學校的社團類別
  async getClubCategories(schoolId: number): Promise<any[]> {
    return apiClient.get(`/api/public/schools/${schoolId}/clubs/categories`)
  }
}