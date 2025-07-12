import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    // 公開路由
    {
      path: '/',
      name: 'home',
      component: () => import('@/pages/public/HomePage.vue'),
      meta: { layout: 'default' }
    },
    {
      path: '/apply',
      name: 'apply',
      component: () => import('@/pages/public/ApplyPage.vue'),
      meta: { layout: 'default' }
    },

    // 超級管理員路由
    {
      path: '/admin',
      name: 'admin',
      component: () => import('@/layouts/AdminLayout.vue'),
      meta: { requiresAuth: true, role: 'user' },
      children: [
        {
          path: '',
          name: 'admin-dashboard',
          component: () => import('@/pages/admin/DashboardPage.vue')
        },
        {
          path: 'schools',
          name: 'admin-schools',
          component: () => import('@/pages/admin/SchoolsPage.vue')
        },
        {
          path: 'schools/:id',
          name: 'admin-school-detail',
          component: () => import('@/pages/admin/SchoolDetailPage.vue')
        },
        {
          path: 'users',
          name: 'admin-users',
          component: () => import('@/pages/admin/UsersPage.vue')
        }
      ]
    },

    // 學校路由（支援多租戶）
    {
      path: '/schools/:schoolId',
      component: () => import('@/layouts/SchoolLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        // 學校管理員路由
        {
          path: 'admin',
          name: 'school-admin',
          component: () => import('@/layouts/SchoolAdminLayout.vue'),
          meta: { role: 'user' },
          children: [
            {
              path: '',
              name: 'school-admin-dashboard',
              component: () => import('@/pages/school-admin/DashboardPage.vue')
            },
            {
              path: 'students',
              name: 'school-admin-students',
              component: () => import('@/pages/school-admin/StudentsPage.vue')
            },
            {
              path: 'students/import',
              name: 'school-admin-students-import',
              component: () => import('@/pages/school-admin/StudentsImportPage.vue')
            },
            {
              path: 'clubs',
              name: 'school-admin-clubs',
              component: () => import('@/pages/school-admin/ClubsPage.vue')
            },
            {
              path: 'clubs/import',
              name: 'school-admin-clubs-import',
              component: () => import('@/pages/school-admin/ClubsImportPage.vue')
            },
            {
              path: 'settings',
              name: 'school-admin-settings',
              component: () => import('@/pages/school-admin/SettingsPage.vue')
            },
            {
              path: 'statistics',
              name: 'school-admin-statistics',
              component: () => import('@/pages/school-admin/StatisticsPage.vue')
            },
            {
              path: 'assignments',
              name: 'school-admin-assignments',
              component: () => import('@/pages/school-admin/AssignmentsPage.vue')
            }
          ]
        },

        // 社團老師路由
        {
          path: 'teacher',
          name: 'teacher',
          component: () => import('@/layouts/TeacherLayout.vue'),
          meta: { role: 'user' },
          children: [
            {
              path: '',
              name: 'teacher-dashboard',
              component: () => import('@/pages/teacher/DashboardPage.vue')
            },
            {
              path: 'clubs/:clubId',
              name: 'teacher-club',
              component: () => import('@/pages/teacher/ClubPage.vue')
            },
            {
              path: 'clubs/:clubId/attendance',
              name: 'teacher-attendance',
              component: () => import('@/pages/teacher/AttendancePage.vue')
            },
            {
              path: 'clubs/:clubId/grades',
              name: 'teacher-grades',
              component: () => import('@/pages/teacher/GradesPage.vue')
            }
          ]
        },

        // 學生路由
        {
          path: 'student',
          name: 'student',
          component: () => import('@/layouts/StudentLayout.vue'),
          children: [
            {
              path: 'login',
              name: 'student-login',
              component: () => import('@/pages/student/LoginPage.vue'),
              meta: { requiresAuth: false }
            },
            {
              path: '',
              name: 'student-dashboard',
              component: () => import('@/pages/student/DashboardPage.vue'),
              meta: { role: 'student' }
            },
            {
              path: 'clubs',
              name: 'student-clubs',
              component: () => import('@/pages/student/ClubsPage.vue'),
              meta: { role: 'student' }
            },
            {
              path: 'choose',
              name: 'student-choose',
              component: () => import('@/pages/student/ChoosePage.vue'),
              meta: { role: 'student' }
            },
            {
              path: 'result',
              name: 'student-result',
              component: () => import('@/pages/student/ResultPage.vue'),
              meta: { role: 'student' }
            }
          ]
        }
      ]
    },

    // 認證路由
    {
      path: '/auth/google',
      name: 'google-auth',
      component: () => import('@/pages/auth/GoogleAuthPage.vue'),
      meta: { layout: 'auth' }
    },

    // 404 頁面
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/pages/NotFoundPage.vue'),
      meta: { layout: 'default' }
    }
  ]
})

// 路由守衛
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // 只在需要認證或有角色要求的路由顯示調試信息
  if (to.meta.requiresAuth || to.meta.role) {
    console.log('Route guard:', { 
      to: to.path, 
      userRole: authStore.userRole, 
      isAuthenticated: authStore.isAuthenticated,
      toRole: to.meta.role 
    })
  }

  // 初始化認證狀態（僅第一次）
  if (!authStore.user && authStore.token) {
    try {
      await authStore.initialize()
    } catch (error) {
      console.error('Auth initialization failed:', error)
    }
  }

  // 檢查是否需要認證
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    // 如果是學生路由，重定向到學生登入頁
    if (to.path.includes('/student')) {
      const schoolId = to.params.schoolId
      return next(`/schools/${schoolId}/student/login`)
    }
    // 其他情況重定向到首頁
    return next('/')
  }

  // 檢查角色權限
  if (to.meta.role && authStore.userRole !== to.meta.role) {
    // 角色不匹配時的處理
    if (authStore.isAuthenticated) {
      // 根據使用者角色重定向到適當的頁面
      switch (authStore.userRole) {
        case 'user':
          // 對於 Google 登入的用戶，導向管理員頁面
          return next('/admin')
        case 'student':
          const studentSchoolId = authStore.currentSchool
          if (studentSchoolId) {
            return next(`/schools/${studentSchoolId}/student`)
          }
          break
      }
    }
    return next('/')
  }

  // 設定當前學校 ID（如果路由包含 schoolId）
  if (to.params.schoolId && typeof to.params.schoolId === 'string') {
    const schoolId = parseInt(to.params.schoolId)
    if (authStore.currentSchool !== schoolId) {
      authStore.setCurrentSchool(schoolId)
    }
  }

  next()
})

export default router
