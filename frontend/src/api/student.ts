import apiClient from './client'
import type { 
  Student, 
  StudentImportData, 
  StudentFilter, 
  StudentStatistics 
} from '@/types/student'

export const studentApi = {
  // 獲取學生列表
  async getStudents(schoolId: number, filters?: StudentFilter): Promise<Student[]> {
    const params = filters ? { ...filters } : undefined
    return apiClient.get(`/api/schools/${schoolId}/students`, { params })
  },

  // 獲取單一學生
  async getStudent(schoolId: number, studentId: number): Promise<Student> {
    return apiClient.get(`/api/schools/${schoolId}/students/${studentId}`)
  },

  // 創建學生
  async createStudent(schoolId: number, studentData: Omit<Student, 'id' | 'school_id' | 'created_at' | 'updated_at'>): Promise<Student> {
    return apiClient.post(`/api/schools/${schoolId}/students`, studentData)
  },

  // 更新學生資料
  async updateStudent(schoolId: number, studentId: number, studentData: Partial<Student>): Promise<Student> {
    return apiClient.patch(`/api/schools/${schoolId}/students/${studentId}`, studentData)
  },

  // 刪除學生
  async deleteStudent(schoolId: number, studentId: number): Promise<void> {
    return apiClient.delete(`/api/schools/${schoolId}/students/${studentId}`)
  },

  // 批量刪除學生
  async deleteStudents(schoolId: number, studentIds: number[]): Promise<void> {
    return apiClient.delete(`/api/schools/${schoolId}/students/batch`, {
      data: { student_ids: studentIds }
    })
  },

  // 匯入學生資料
  async importStudents(schoolId: number, file: File, onProgress?: (progress: number) => void): Promise<{
    imported: number
    errors: string[]
    preview: Student[]
  }> {
    return apiClient.upload(`/api/schools/${schoolId}/students/import`, file, onProgress)
  },

  // 匯出學生資料
  async exportStudents(schoolId: number, format: 'excel' | 'csv' | 'json' = 'excel'): Promise<Blob> {
    const response = await apiClient.getRawClient().get(`/api/schools/${schoolId}/students/export`, {
      params: { format },
      responseType: 'blob'
    })
    return response.data
  },

  // 獲取學生統計資料
  async getStudentStatistics(schoolId: number): Promise<StudentStatistics> {
    return apiClient.get(`/api/schools/${schoolId}/students/statistics`)
  },

  // 搜尋學生
  async searchStudents(schoolId: number, query: string): Promise<Student[]> {
    return apiClient.get(`/api/schools/${schoolId}/students/search`, {
      params: { q: query }
    })
  },

  // 獲取學生選社記錄
  async getStudentSelections(schoolId: number, studentId: number): Promise<any[]> {
    return apiClient.get(`/api/schools/${schoolId}/students/${studentId}/selections`)
  },

  // 重置學生選社狀態（允許重新選社）
  async resetStudentSelection(schoolId: number, studentId: number): Promise<void> {
    return apiClient.post(`/api/schools/${schoolId}/students/${studentId}/reset-selection`)
  },

  // 指定學生到特定社團
  async assignStudentToClub(schoolId: number, studentId: number, clubId: number): Promise<void> {
    return apiClient.post(`/api/schools/${schoolId}/students/${studentId}/assign`, {
      club_id: clubId
    })
  }
}