export interface Club {
  id: number
  category: string
  club_number: string
  name: string
  teacher_name: string
  description: string
  max_members: number
  location: string
  rainy_day_location?: string
  note?: string
  condition1?: number
  condition2?: number
  condition3?: string
  teacher_email?: string
  school_id: number
  current_members?: number
  created_at: string
  updated_at: string
}

export interface ClubImportData {
  category: string
  club_number: string
  name: string
  teacher_name: string
  description: string
  max_members: number
  location: string
  rainy_day_location?: string
  note?: string
  condition1?: number
  condition2?: number
  condition3?: string
  teacher_email?: string
}

export interface ClubFilter {
  category?: string
  search?: string
  condition1?: number
  condition2?: number
  has_available_spots?: boolean
}

export interface ClubStatistics {
  total: number
  by_category: Record<string, number>
  total_capacity: number
  total_current_members: number
  available_spots: number
  full_clubs: number
}

export interface ClubSelection {
  id: number
  student_id: number
  student_name?: string
  club_id: number
  club_name?: string
  preference: number
  priority?: number
  status?: 'pending' | 'assigned' | 'rejected'
  school_id?: number
  created_at: string
  updated_at: string
  student?: Student
  club?: Club
}

export interface ClubSelectionRequest {
  club_choices: number[] // club IDs in priority order
}

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
  condition3?: string
  school_id: number
  created_at: string
  updated_at: string
}