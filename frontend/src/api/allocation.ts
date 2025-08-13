import { apiClient } from './client'

export interface AllocationStatistics {
  total_students: number
  assigned_students: number  
  unassigned_students: number
  assignment_by_type: {
    special?: number
    normal?: number
    manual?: number
  }
  club_member_counts: Record<string, number>
}

export interface AllocationLogEntry {
  timestamp: string
  level: 'INFO' | 'WARNING' | 'ERROR'
  message: string
}

export interface AllocationResult {
  success: boolean
  message: string
  statistics?: AllocationStatistics
  warnings?: string[]
  total_log_entries: number
  detailed_log?: AllocationLogEntry[]
  error?: string
  log?: AllocationLogEntry[]
}

export interface SystemCheckResult {
  studentCount: number
  clubCount: number
  selectionCount: number
  warnings: string[]
  errors: string[]
}

export const allocationApi = {
  // 執行社團分發
  async allocateClubs(schoolId: number, includeLog: boolean = true): Promise<AllocationResult> {
    const params = includeLog ? { include_log: 'true' } : {}
    // 分發可能需要較長時間，設置更長的超時時間（3分鐘）
    return await apiClient.post(
      `/api/schools/${schoolId}/club_selections/allocate_clubs`, 
      {}, 
      { 
        params,
        timeout: 180000 // 3 分鐘
      }
    )
  },

  // 檢查系統狀態（使用現有的統計 API）
  async checkSystemStatus(schoolId: number): Promise<SystemCheckResult> {
    try {
      // 使用現有的統計 API 來獲取系統狀態
      const stats = await apiClient.get(`/api/schools/${schoolId}/statistics`)
      
      const warnings: string[] = []
      const errors: string[] = []
      
      // 檢查基本數據
      if (stats.total_students === 0) {
        errors.push('沒有學生資料，請先匯入學生')
      }
      
      if (stats.total_clubs === 0) {
        errors.push('沒有社團資料，請先建立社團')
      }
      
      if (stats.total_selections === 0 && stats.total_students > 0) {
        errors.push('沒有學生選社記錄')
      }
      
      // 檢查選社狀況
      const unselected_students = stats.total_students - stats.students_with_selections
      if (unselected_students > 0) {
        warnings.push(`有 ${unselected_students} 位學生尚未選社`)
      }
      
      // 檢查特殊學生
      if (stats.special_students > 0) {
        warnings.push(`有 ${stats.special_students} 位特殊學生將優先分配`)
      }
      
      // 檢查是否已有分發記錄
      try {
        const membershipCheck = await apiClient.get(`/api/schools/${schoolId}/club_memberships/count`)
        if (membershipCheck.count > 0) {
          warnings.push(`⚠️ 已存在分發記錄（${membershipCheck.count} 筆），重新分發將覆蓋現有資料`)
        }
      } catch (error) {
        // 如果 API 不存在，嘗試其他方式檢查
        console.warn('Club membership count API not available, checking via statistics')
        if (stats.allocated_students > 0) {
          warnings.push(`⚠️ 已存在分發記錄，重新分發將覆蓋現有資料`)
        }
      }
      
      return {
        studentCount: stats.total_students || 0,
        clubCount: stats.total_clubs || 0,
        selectionCount: stats.total_selections || 0,
        warnings,
        errors
      }
    } catch (error: any) {
      console.error('System check failed:', error)
      return {
        studentCount: 0,
        clubCount: 0,
        selectionCount: 0,
        warnings: [],
        errors: [error.message || '無法獲取系統狀態']
      }
    }
  },

  // 取得分發結果統計
  async getAllocationStatistics(schoolId: number): Promise<AllocationStatistics> {
    return await apiClient.get(`/api/schools/${schoolId}/allocation/statistics`)
  },

  // 取得未分配學生清單
  async getUnassignedStudents(schoolId: number) {
    return await apiClient.get(`/api/schools/${schoolId}/allocation/unassigned_students`)
  },

  // 取得分發日誌
  async getAllocationLog(schoolId: number): Promise<AllocationLogEntry[]> {
    return await apiClient.get(`/api/schools/${schoolId}/allocation/log`)
  }
}