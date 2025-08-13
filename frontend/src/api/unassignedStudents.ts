import { apiClient } from './client'

export interface UnassignedStudent {
  id: number
  name: string
  grade: number
  class_name: string
  class_number: number
  seat_number: number
  student_id: string
  condition1?: number
  condition2?: number
  condition3?: number
  selectedClubId?: string
}

export interface AvailableClub {
  id: number
  name: string
  category: string
  teacher_name: string
  location: string
  max_members: number
  current_members: number
  available_spots: number
  condition1?: number
  condition2?: number
  condition3?: number
}

export interface AssignmentResult {
  success: boolean
  message: string
  student: UnassignedStudent
  club: AvailableClub
}

export const unassignedStudentsApi = {
  // 取得未分配的學生清單
  async getUnassignedStudents(schoolId: number): Promise<UnassignedStudent[]> {
    return await apiClient.get(`/api/schools/${schoolId}/unassigned_students`)
  },

  // 取得有空位的社團清單
  async getAvailableClubs(schoolId: number): Promise<AvailableClub[]> {
    return await apiClient.get(`/api/schools/${schoolId}/available_clubs`)
  },

  // 手動分配學生到社團
  async assignStudentToClub(schoolId: number, studentId: number, clubId: number): Promise<AssignmentResult> {
    return await apiClient.post(`/api/schools/${schoolId}/manual_assignment`, {
      student_id: studentId,
      club_id: clubId
    })
  },

  // 批量分配學生到社團
  async bulkAssignStudentsToClub(
    schoolId: number, 
    studentIds: number[], 
    clubId: number
  ): Promise<{
    success: boolean
    message: string
    assigned_count: number
    failed_assignments: { student_id: number, reason: string }[]
  }> {
    return await apiClient.post(`/api/schools/${schoolId}/bulk_assignment`, {
      student_ids: studentIds,
      club_id: clubId
    })
  },

  // 取得分配統計
  async getAssignmentStatistics(schoolId: number) {
    return await apiClient.get(`/api/schools/${schoolId}/assignment_statistics`)
  }
}