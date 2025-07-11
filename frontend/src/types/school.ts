export interface School {
  id: number
  name: string
  description?: string
  applicant_name?: string
  applicant_email?: string
  status: 'pending' | 'approved' | 'rejected'
  created_at: string
  updated_at: string
}

export interface SchoolSetting {
  id: number
  school_id: number
  welcome_message?: string
  registration_start_date?: string
  registration_end_date?: string
  assignment_date?: string
  is_registration_open: boolean
  max_choices: number
  allow_change_after_submit: boolean
  settings_data: Record<string, any>
  created_at: string
  updated_at: string
}

export interface SchoolApplication {
  name: string
  description?: string
  contact_email?: string
}

export interface SchoolStatistics {
  total_students: number
  total_clubs: number
  total_selections: number
  total_applications: number
  assigned_students: number
  students_without_selection: number
  clubs_with_available_spots: number
  assignment_completion_rate: number
}