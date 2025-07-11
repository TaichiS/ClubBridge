export interface User {
  id: number
  name: string
  email: string
  type: 'user' | 'student'
  // 學生專用欄位 (當 type 為 'student' 時)
  student_id?: string
  grade?: number
  class_name?: string
  // 系統欄位
  api_token?: string
  created_at?: string
  updated_at?: string
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
  // Google 登入用
  email?: string
  // 學生登入用
  student_id?: string
  id_number?: string
  school_id?: number
}

export interface GoogleAuthResponse {
  user: User
  token: string
}

export interface StudentAuthResponse {
  student: Student
  token: string
  school: School
}

export interface Student {
  id: number
  student_id: string
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
  type: 'student'
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