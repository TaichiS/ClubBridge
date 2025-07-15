export interface School {
  id: number
  name: string
  school_type?: string
  address?: string
  website?: string
  description?: string
  contact_name?: string
  contact_title?: string
  contact_email?: string
  contact_phone?: string
  student_count?: string
  club_count?: string
  expected_start_date?: string
  notes?: string
  applicant_name?: string
  applicant_email?: string
  rejection_reason?: string
  status: 'pending' | 'approved' | 'rejected'
  club_selection_start_time?: string
  club_selection_end_time?: string
  result_announcement_start_time?: string
  result_announcement_end_time?: string
  semester_schedule?: string
  announcement?: string
  top_announcement?: string
  min_required_choices?: number
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
  school_type?: string
  address?: string
  website?: string
  description?: string
  contact_name?: string
  contact_title?: string
  contact_email?: string
  contact_phone?: string
  student_count?: string
  club_count?: string
  expected_start_date?: string
  notes?: string
  applicant_name?: string
  applicant_email?: string
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