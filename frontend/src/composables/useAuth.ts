import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { LoginCredentials } from '@/types/auth'

export function useAuth() {
  const authStore = useAuthStore()
  const router = useRouter()
  
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const isAuthenticated = computed(() => authStore.isAuthenticated)
  const user = computed(() => authStore.user)
  const userRole = computed(() => authStore.userRole)
  const currentSchool = computed(() => authStore.currentSchool)

  // Google OAuth 登入
  async function loginWithGoogle() {
    isLoading.value = true
    error.value = null

    try {
      // 載入 Google Identity Services
      await loadGoogleScript()
      
      // 初始化 Google OAuth
      const client = google.accounts.oauth2.initTokenClient({
        client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
        scope: 'openid email profile',
        callback: async (response) => {
          try {
            if (response.access_token) {
              await authStore.googleLogin(response.access_token)
              
              // 根據使用者角色導向適當頁面
              await redirectAfterLogin()
            }
          } catch (err) {
            console.error('Google login callback error:', err)
            error.value = err instanceof Error ? err.message : 'Google 登入失敗'
          } finally {
            isLoading.value = false
          }
        },
      })

      // 請求 token
      client.requestAccessToken()
    } catch (err) {
      console.error('Google login error:', err)
      error.value = err instanceof Error ? err.message : 'Google 登入失敗'
      isLoading.value = false
    }
  }

  // 學生登入
  async function loginAsStudent(credentials: LoginCredentials) {
    isLoading.value = true
    error.value = null

    try {
      await authStore.studentLogin(credentials)
      await redirectAfterLogin()
    } catch (err) {
      console.error('Student login error:', err)
      error.value = err instanceof Error ? err.message : '學生登入失敗'
    } finally {
      isLoading.value = false
    }
  }

  // 登出
  async function logout() {
    isLoading.value = true
    error.value = null

    try {
      await authStore.logout()
      router.push('/')
    } catch (err) {
      console.error('Logout error:', err)
      error.value = err instanceof Error ? err.message : '登出失敗'
    } finally {
      isLoading.value = false
    }
  }

  // 根據角色重定向
  async function redirectAfterLogin() {
    const role = authStore.userRole
    const schoolId = authStore.currentSchool

    switch (role) {
      case 'super_admin':
        router.push('/admin')
        break
      case 'school_admin':
        if (schoolId) {
          router.push(`/schools/${schoolId}/admin`)
        } else {
          // 如果沒有學校，需要選擇學校
          router.push('/select-school')
        }
        break
      case 'teacher':
        if (schoolId) {
          router.push(`/schools/${schoolId}/teacher`)
        } else {
          router.push('/select-school')
        }
        break
      case 'student':
        if (schoolId) {
          router.push(`/schools/${schoolId}/student`)
        } else {
          router.push('/')
        }
        break
      default:
        router.push('/')
    }
  }

  // 載入 Google Script
  function loadGoogleScript(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (typeof google !== 'undefined') {
        resolve()
        return
      }

      const script = document.createElement('script')
      script.src = 'https://accounts.google.com/gsi/client'
      script.async = true
      script.defer = true
      script.onload = () => resolve()
      script.onerror = () => reject(new Error('Failed to load Google script'))
      document.head.appendChild(script)
    })
  }

  // 檢查認證狀態
  async function checkAuthState() {
    try {
      await authStore.initialize()
    } catch (err) {
      console.error('Auth state check failed:', err)
      error.value = '認證狀態檢查失敗'
    }
  }

  // 清除錯誤
  function clearError() {
    error.value = null
  }

  return {
    // State
    isLoading,
    error,
    
    // Getters
    isAuthenticated,
    user,
    userRole,
    currentSchool,
    
    // Actions
    loginWithGoogle,
    loginAsStudent,
    logout,
    checkAuthState,
    clearError,
    redirectAfterLogin
  }
}