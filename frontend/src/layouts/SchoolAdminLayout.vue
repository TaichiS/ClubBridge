<template>
  <div class="min-h-screen bg-gray-50">
    <div class="flex">
      <!-- 側邊導航選單 -->
      <nav class="w-64 bg-white shadow-lg border-r border-gray-200">
        <!-- 學校資訊標題 -->
        <div class="p-6 border-b border-gray-200">
          <h2 class="text-xl font-bold text-gray-800">學校管理系統</h2>
          <p class="text-sm text-gray-600 mt-1">{{ schoolName }}</p>
        </div>

        <!-- 導航選單 -->
        <div class="py-4">
          <!-- 學期管理 -->
          <div class="px-4 mb-4">
            <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">學期管理</h3>
            <nav class="space-y-1">
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/semester-setup`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/semester-setup') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"/>
                </svg>
                學期初設定
              </router-link>

              <router-link
                :to="`/schools/${route.params.schoolId}/admin/announcement`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/announcement') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"/>
                </svg>
                編輯公告
              </router-link>
              
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/backup`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/backup') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3-3m0 0l-3 3m3-3v12"/>
                </svg>
                資料備份
              </router-link>
            </nav>
          </div>

          <!-- 資料管理 -->
          <div class="px-4 mb-4">
            <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">資料管理</h3>
            <nav class="space-y-1">
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/students`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/students') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"/>
                </svg>
                學生管理
              </router-link>
              
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/clubs`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/clubs') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                </svg>
                社團管理
              </router-link>
            </nav>
          </div>

          <!-- 選社管理 -->
          <div class="px-4 mb-4">
            <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">選社管理</h3>
            <nav class="space-y-1">
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/statistics`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/statistics') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                </svg>
                即時統計
              </router-link>
              
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/assignment`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/assignment') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                </svg>
                開始分發
              </router-link>
              
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/results`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/results') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                </svg>
                選社結果
              </router-link>
            </nav>
          </div>

          <!-- 系統設定 -->
          <div class="px-4 mb-4">
            <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">系統設定</h3>
            <nav class="space-y-1">
              
              <router-link
                :to="`/schools/${route.params.schoolId}/admin/settings`"
                class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors"
                :class="isActive('/admin/settings') ? 'bg-blue-100 text-blue-700' : 'text-gray-700 hover:bg-gray-100'"
              >
                <svg class="mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                學校資訊
              </router-link>
            </nav>
          </div>
        </div>

        <!-- 用戶資訊和登出 -->
        <div class="absolute bottom-0 w-64 p-4 border-t border-gray-200 bg-white">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center">
                <span class="text-sm font-medium text-white">{{ userInitial }}</span>
              </div>
            </div>
            <div class="ml-3 flex-1">
              <p class="text-sm font-medium text-gray-700">{{ currentUser?.name || '管理員' }}</p>
              <p class="text-xs text-gray-500">學校管理員</p>
            </div>
            <button
              @click="handleLogout"
              class="ml-2 p-2 text-gray-400 hover:text-gray-600 transition-colors"
              title="登出"
            >
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
              </svg>
            </button>
          </div>
        </div>
      </nav>

      <!-- 主要內容區域 -->
      <main class="flex-1 overflow-auto">
        <router-view />
      </main>
    </div>
  </div>
</template>
<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { schoolApi } from '@/api/school'
import type { School } from '@/types/school'

const route = useRoute()
const { user, currentSchool, logout } = useAuth()

// 學校資料
const schoolData = ref<School | null>(null)

// 計算屬性：學校名稱
const schoolName = computed(() => {
  return schoolData.value?.name || '載入中...'
})

// 計算屬性：用戶名首字母
const userInitial = computed(() => {
  if (!user.value) return 'A'
  
  const userValue = user.value as any
  
  if (userValue.name) {
    const name = userValue.name
    // 如果是中文姓名，取最後一個字
    if (/[\u4e00-\u9fa5]/.test(name)) {
      return name.charAt(name.length - 1)
    }
    // 英文姓名取首字母
    return name.charAt(0).toUpperCase()
  }
  
  if (userValue.email) {
    return userValue.email.charAt(0).toUpperCase()
  }
  
  return 'A'
})

// 計算屬性：用戶顯示名稱
const currentUser = computed(() => {
  if (!user.value) return null
  
  const userValue = user.value as any
  
  if (userValue.name) {
    return {
      name: userValue.name || '管理員',
      email: userValue.email || ''
    }
  }
  
  if (userValue.email) {
    return {
      name: userValue.email.split('@')[0] || '管理員',
      email: userValue.email || ''
    }
  }
  
  return {
    name: '管理員',
    email: ''
  }
})

// 檢查當前路由是否活躍
const isActive = (path: string): boolean => {
  return route.path.includes(path)
}

// 處理登出
const handleLogout = async () => {
  try {
    await logout()
  } catch (error) {
    console.error('登出失敗:', error)
  }
}

// 載入學校資料
const loadSchoolData = async () => {
  const schoolId = route.params.schoolId
  if (!schoolId) return
  
  try {
    schoolData.value = await schoolApi.getSchool(Number(schoolId))
  } catch (error) {
    console.error('載入學校資料失敗:', error)
  }
}

// 組件掛載時載入學校資料
onMounted(() => {
  loadSchoolData()
})
</script>
