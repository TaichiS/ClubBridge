export interface User {
  id: number
  email: string
  role: 'super_admin' | 'school_admin' | 'teacher' | 'student'
  api_token?: string
  created_at: string
  updated_at: string
}

export interface Membership {
  id: number
  user_id: number
  school_id: number
  role: 'admin' | 'member'
  created_at: string
  updated_at: string
}

export interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  currentSchool: number | null
}

export interface LoginCredentials {
  email?: string
  student_number?: string
  id_number?: string
}

export interface GoogleAuthResponse {
  user: User
  token: string
  memberships: Membership[]
}

export interface StudentAuthResponse {
  student: Student
  token: string
  school: School
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

export interface School {
  id: number
  name: string
  status: 'pending' | 'approved' | 'rejected'
  created_at: string
  updated_at: string
}