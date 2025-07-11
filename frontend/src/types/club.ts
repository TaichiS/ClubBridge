export interface Club {
  id: number
  category: string
  code: string
  name: string
  instructor: string
  description: string
  max_members: number
  location: string
  rainy_location?: string
  notes?: string
  condition_1?: number
  condition_2?: number
  condition_3?: string
  instructor_email?: string
  school_id: number
  current_members?: number
  created_at: string
  updated_at: string
}

export interface ClubImportData {
  category: string
  code: string
  name: string
  instructor: string
  description: string
  max_members: number
  location: string
  rainy_location?: string
  notes?: string
  condition_1?: number
  condition_2?: number
  condition_3?: string
  instructor_email?: string
}

export interface ClubFilter {
  category?: string
  search?: string
  condition_1?: number
  condition_2?: number
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
  club_id: number
  priority: number
  status: 'pending' | 'assigned' | 'rejected'
  school_id: number
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
  condition_1?: number
  condition_2?: number
  condition_3?: string
  school_id: number
  created_at: string
  updated_at: string
}