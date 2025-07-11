import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from './useAuth'

export function useAuthGuard() {
  const router = useRouter()
  const route = useRoute()
  const { isAuthenticated, userRole, currentSchool } = useAuth()

  // 檢查是否有指定角色的權限
  const hasRole = computed(() => {
    return (requiredRole: string) => {
      if (!isAuthenticated.value) return false
      if (!requiredRole) return true
      return userRole.value === requiredRole
    }
  })

  // 檢查是否有訪問指定學校的權限
  const canAccessSchool = computed(() => {
    return (schoolId: number) => {
      if (!isAuthenticated.value) return false
      
      // 超級管理員可以訪問所有學校
      if (userRole.value === 'super_admin') return true
      
      // 其他角色只能訪問自己的學校
      return currentSchool.value === schoolId
    }
  })

  // 檢查是否為管理員
  const isAdmin = computed(() => {
    return userRole.value === 'super_admin' || userRole.value === 'school_admin'
  })

  // 檢查是否為超級管理員
  const isSuperAdmin = computed(() => {
    return userRole.value === 'super_admin'
  })

  // 檢查是否為學校管理員
  const isSchoolAdmin = computed(() => {
    return userRole.value === 'school_admin'
  })

  // 檢查是否為老師
  const isTeacher = computed(() => {
    return userRole.value === 'teacher'
  })

  // 檢查是否為學生
  const isStudent = computed(() => {
    return userRole.value === 'student'
  })

  // 重定向到適當的頁面
  function redirectToAppropriateRoute() {
    if (!isAuthenticated.value) {
      router.push('/')
      return
    }

    const role = userRole.value
    const schoolId = currentSchool.value

    switch (role) {
      case 'super_admin':
        router.push('/admin')
        break
      case 'school_admin':
        if (schoolId) {
          router.push(`/schools/${schoolId}/admin`)
        } else {
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

  // 檢查並重定向未授權的用戶
  function requireAuth(requiredRole?: string) {
    if (!isAuthenticated.value) {
      // 如果是學生路由，重定向到學生登入頁
      if (route.path.includes('/student')) {
        const schoolId = route.params.schoolId
        router.push(`/schools/${schoolId}/student/login`)
      } else {
        router.push('/auth/google')
      }
      return false
    }

    if (requiredRole && !hasRole.value(requiredRole)) {
      redirectToAppropriateRoute()
      return false
    }

    return true
  }

  // 檢查學校訪問權限
  function requireSchoolAccess(schoolId: number) {
    if (!canAccessSchool.value(schoolId)) {
      redirectToAppropriateRoute()
      return false
    }
    return true
  }

  // 阻止已登入用戶訪問登入頁
  function requireGuest() {
    if (isAuthenticated.value) {
      redirectToAppropriateRoute()
      return false
    }
    return true
  }

  return {
    // State
    isAuthenticated,
    userRole,
    currentSchool,
    
    // Computed
    hasRole,
    canAccessSchool,
    isAdmin,
    isSuperAdmin,
    isSchoolAdmin,
    isTeacher,
    isStudent,
    
    // Methods
    requireAuth,
    requireSchoolAccess,
    requireGuest,
    redirectToAppropriateRoute
  }
}