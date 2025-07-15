export interface Student {
  id: number
  student_number: string
  name: string
  grade: number
  class_number: number
  class_name: string
  seat_number: number
  id_number: string
  condition1?: number
  condition2?: number
  condition3?: number
  school_id: number
  has_selection: boolean
  assigned_club?: string
  created_at: string
  updated_at: string
}

export interface StudentImportData {
  grade: number
  class_number: number
  class_name: string
  seat_number: number
  student_number: string
  name: string
  id_number: string
  condition1?: number
  condition2?: number
  condition3?: number
}

export interface StudentFilter {
  grade?: number
  class_number?: number
  class_name?: string
  search?: string
  condition1?: number
  condition2?: number
}

export interface StudentStatistics {
  total: number
  by_grade: Record<number, number>
  by_class: Record<string, number>
  with_conditions: {
    condition1: Record<number, number>
    condition2: Record<number, number>
  }
}