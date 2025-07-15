import apiClient from './client'
import type { 
  Club, 
  ClubImportData, 
  ClubFilter, 
  ClubStatistics,
  ClubSelection,
  ClubSelectionRequest
} from '@/types/club'

export const clubApi = {
  // 獲取社團列表
  async getClubs(schoolId: number, filters?: ClubFilter): Promise<Club[]> {
    const params = filters ? { ...filters } : undefined
    return apiClient.get(`/api/schools/${schoolId}/clubs`, { params })
  },

  // 獲取單一社團
  async getClub(schoolId: number, clubId: number): Promise<Club> {
    return apiClient.get(`/api/schools/${schoolId}/clubs/${clubId}`)
  },

  // 創建社團
  async createClub(schoolId: number, clubData: Omit<Club, 'id' | 'school_id' | 'current_members' | 'created_at' | 'updated_at'>): Promise<Club> {
    return apiClient.post(`/api/schools/${schoolId}/clubs`, clubData)
  },

  // 更新社團資料
  async updateClub(schoolId: number, clubId: number, clubData: Partial<Club>): Promise<Club> {
    return apiClient.patch(`/api/schools/${schoolId}/clubs/${clubId}`, clubData)
  },

  // 刪除社團
  async deleteClub(schoolId: number, clubId: number): Promise<void> {
    return apiClient.delete(`/api/schools/${schoolId}/clubs/${clubId}`)
  },

  // 批量刪除社團
  async deleteClubs(schoolId: number, clubIds: number[]): Promise<void> {
    return apiClient.delete(`/api/schools/${schoolId}/clubs/batch`, {
      data: { club_ids: clubIds }
    })
  },

  // 匯入社團資料
  async importClubs(schoolId: number, file: File, onProgress?: (progress: number) => void): Promise<{
    imported: number
    errors: string[]
    preview: Club[]
  }> {
    return apiClient.upload(`/api/schools/${schoolId}/clubs/import`, file, onProgress)
  },

  // 匯出社團資料
  async exportClubs(schoolId: number, format: 'excel' | 'csv' | 'json' = 'excel'): Promise<Blob> {
    const response = await apiClient.getRawClient().get(`/api/schools/${schoolId}/clubs/export`, {
      params: { format },
      responseType: 'blob'
    })
    return response.data
  },

  // 獲取社團統計資料
  async getClubStatistics(schoolId: number): Promise<ClubStatistics> {
    return apiClient.get(`/api/schools/${schoolId}/clubs/statistics`)
  },

  // 獲取即時統計資料
  async getRealtimeStats(schoolId: number): Promise<{
    clubs: Array<{
      id: number
      name: string
      max_members: number
      current_members: number
      available_spots: number
    }>
  }> {
    return apiClient.get(`/api/schools/${schoolId}/clubs/realtime`)
  },

  // 搜尋社團
  async searchClubs(schoolId: number, query: string): Promise<Club[]> {
    return apiClient.get(`/api/schools/${schoolId}/clubs/search`, {
      params: { q: query }
    })
  },

  // 獲取社團成員列表
  async getClubMembers(schoolId: number, clubId: number): Promise<any[]> {
    return apiClient.get(`/api/schools/${schoolId}/clubs/${clubId}/members`)
  },

  // 社團選擇相關 API
  
  // 提交學生選社志願
  async submitClubSelection(schoolId: number, _studentId: number, selections: ClubSelectionRequest): Promise<any> {
    return apiClient.post(`/api/student/schools/${schoolId}/club_selections`, selections)
  },

  // 獲取學生的選社記錄
  async getStudentSelections(schoolId: number, _studentId?: number): Promise<ClubSelection[]> {
    return apiClient.get(`/api/student/schools/${schoolId}/club_selections`)
  },

  // 獲取所有選社記錄（管理員用）
  async getAllSelections(schoolId: number): Promise<ClubSelection[]> {
    return apiClient.get(`/api/schools/${schoolId}/club_selections`)
  },

  // 啟動社團分發
  async startAssignment(schoolId: number): Promise<{
    message: string
    assigned: number
    unassigned: number
  }> {
    return apiClient.post(`/api/schools/${schoolId}/assign`)
  },

  // 獲取分發結果
  async getAssignmentResults(schoolId: number): Promise<{
    assignments: Array<{
      student_id: number
      student_name: string
      club_id: number
      club_name: string
      priority: number
    }>
    unassigned_students: Array<{
      id: number
      name: string
      student_number: string
    }>
  }> {
    return apiClient.get(`/api/schools/${schoolId}/assignments`)
  }
}