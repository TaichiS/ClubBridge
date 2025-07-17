import apiClient from './client'
import type { Student } from '@/types/student'
import type { Club } from '@/types/club'

export interface SpecialStudent {
  id: number
  name: string
  student_number: string  // 學號
  grade: number
  class_number: number
  class_name: string
  seat_number: number
  special: number
  assigned_club?: {
    id: number
    name: string
    number: string
  }
}

export interface AssignmentResponse {
  message: string
  student: {
    id: number
    name: string
    student_number: string
    special: number
  }
  club: {
    id: number
    name: string
    number: string
  }
  selection: {
    id: number
    preference: number
  }
}

export const assignmentApi = {
  // 獲取特殊身份學生列表
  async getSpecialStudents(schoolId: number): Promise<SpecialStudent[]> {
    return apiClient.get(`/api/schools/${schoolId}/club_selections/special_students`)
  },

  // 搜尋學生
  async searchStudents(schoolId: number, query: string): Promise<Student[]> {
    return apiClient.get(`/api/schools/${schoolId}/club_selections/search_students`, {
      params: { query }
    })
  },

  // 指定學生入社
  async assignStudentToClub(schoolId: number, studentId: number, clubId: number, forceOverride?: boolean): Promise<AssignmentResponse> {
    return apiClient.post(`/api/schools/${schoolId}/club_selections/assign_student`, {
      student_id: studentId,
      club_id: clubId,
      force_override: forceOverride || false
    })
  },

  // 撤銷學生特殊身份
  async revokeSpecialStatus(schoolId: number, studentId: number): Promise<{
    message: string
    student: {
      id: number
      name: string
      student_id: string
      special: number
    }
  }> {
    return apiClient.delete(`/api/schools/${schoolId}/club_selections/revoke_special_status`, {
      data: { student_id: studentId }
    })
  },

  // 搜尋社團
  async searchClubs(schoolId: number, query: string): Promise<Club[]> {
    return apiClient.get(`/api/schools/${schoolId}/clubs`, {
      params: { q: query }
    })
  }
}