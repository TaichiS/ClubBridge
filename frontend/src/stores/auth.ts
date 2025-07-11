import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { authApi } from '@/api/auth'
import type { User, AuthState, LoginCredentials, GoogleAuthResponse, StudentAuthResponse } from '@/types/auth'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('auth_token'))
  const currentSchool = ref<number | null>(Number(localStorage.getItem('current_school')) || null)
  const isLoading = ref(false)

  // Getters
  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const userRole = computed(() => user.value?.role)
  const isAdmin = computed(() => userRole.value === 'super_admin')
  const isSchoolAdmin = computed(() => userRole.value === 'school_admin')
  const isTeacher = computed(() => userRole.value === 'teacher')
  const isStudent = computed(() => userRole.value === 'student')

  // Actions
  async function googleLogin(googleToken: string): Promise<void> {
    isLoading.value = true
    try {
      const response: GoogleAuthResponse = await authApi.googleLogin(googleToken)
      
      setAuthData({
        user: response.user,
        token: response.token,
        currentSchool: null // 讓使用者選擇學校
      })
    } catch (error) {
      console.error('Google login failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function studentLogin(credentials: LoginCredentials): Promise<void> {
    isLoading.value = true
    try {
      const response: StudentAuthResponse = await authApi.studentLogin(credentials)
      
      // 學生登入會自動設定學校
      setAuthData({
        user: response.student as any, // 將 student 當作 user 使用
        token: response.token,
        currentSchool: response.school.id
      })
    } catch (error) {
      console.error('Student login failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function logout(): Promise<void> {
    try {
      await authApi.logout()
    } catch (error) {
      console.error('Logout API call failed:', error)
    } finally {
      clearAuthData()
    }
  }

  async function refreshToken(): Promise<void> {
    try {
      const response = await authApi.refreshToken()
      token.value = response.token
      localStorage.setItem('auth_token', response.token)
    } catch (error) {
      console.error('Token refresh failed:', error)
      clearAuthData()
      throw error
    }
  }

  async function getCurrentUser(): Promise<void> {
    if (!token.value) return

    try {
      const currentUser = await authApi.getCurrentUser()
      user.value = currentUser
    } catch (error) {
      console.error('Get current user failed:', error)
      clearAuthData()
      throw error
    }
  }

  function setAuthData(authData: { user: User; token: string; currentSchool: number | null }) {
    user.value = authData.user
    token.value = authData.token
    currentSchool.value = authData.currentSchool

    // 持久化儲存
    localStorage.setItem('auth_token', authData.token)
    if (authData.currentSchool) {
      localStorage.setItem('current_school', authData.currentSchool.toString())
    } else {
      localStorage.removeItem('current_school')
    }
  }

  function clearAuthData() {
    user.value = null
    token.value = null
    currentSchool.value = null
    
    // 清除持久化儲存
    localStorage.removeItem('auth_token')
    localStorage.removeItem('current_school')
  }

  function setCurrentSchool(schoolId: number) {
    currentSchool.value = schoolId
    localStorage.setItem('current_school', schoolId.toString())
  }

  // 初始化時嘗試恢復使用者狀態
  async function initialize() {
    if (token.value) {
      try {
        await getCurrentUser()
      } catch (error) {
        console.error('Failed to initialize auth state:', error)
        clearAuthData()
      }
    }
  }

  return {
    // State
    user,
    token,
    currentSchool,
    isLoading,
    
    // Getters
    isAuthenticated,
    userRole,
    isAdmin,
    isSchoolAdmin,
    isTeacher,
    isStudent,
    
    // Actions
    googleLogin,
    studentLogin,
    logout,
    refreshToken,
    getCurrentUser,
    setCurrentSchool,
    initialize,
    clearAuthData
  }
})