export interface Student {
  id: number
  student_number: string
  name: string
  grade: number
  class_number: number
  class_name: string
  seat_number: number
  id_number: string
  condition_1?: number
  condition_2?: number
  condition_3?: string
  school_id: number
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
  condition_1?: number
  condition_2?: number
  condition_3?: string
}

export interface StudentFilter {
  grade?: number
  class_number?: number
  class_name?: string
  search?: string
  condition_1?: number
  condition_2?: number
}

export interface StudentStatistics {
  total: number
  by_grade: Record<number, number>
  by_class: Record<string, number>
  with_conditions: {
    condition_1: Record<number, number>
    condition_2: Record<number, number>
  }
}