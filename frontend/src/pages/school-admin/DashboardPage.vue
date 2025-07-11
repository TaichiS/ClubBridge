<template>
  <div class="p-8">
    <div class="mb-6">
      <h1 class="text-3xl font-bold text-gray-900">學校管理儀表板</h1>
      <p class="text-gray-600 mt-2">歡迎使用 {{ school?.name }} 管理系統</p>
    </div>

    <div v-if="isLoading" class="text-center py-8">
      <div class="text-lg">載入中...</div>
    </div>

    <div v-else class="space-y-6">
      <!-- 快速統計 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-blue-100">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">學生總數</p>
              <p class="text-2xl font-bold text-gray-900">{{ statistics?.total_students || 0 }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-green-100">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">社團總數</p>
              <p class="text-2xl font-bold text-gray-900">{{ statistics?.total_clubs || 0 }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-yellow-100">
              <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">選社申請</p>
              <p class="text-2xl font-bold text-gray-900">{{ statistics?.total_selections || 0 }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-purple-100">
              <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">已分發學生</p>
              <p class="text-2xl font-bold text-gray-900">{{ statistics?.assigned_students || 0 }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 系統狀態 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">系統狀態</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
            <div>
              <p class="text-sm font-medium text-gray-600">選社系統</p>
              <p class="text-lg font-semibold" :class="isRegistrationOpen ? 'text-green-600' : 'text-red-600'">
                {{ isRegistrationOpen ? '開放中' : '已關閉' }}
              </p>
            </div>
            <div class="text-right">
              <button
                @click="toggleRegistration"
                :disabled="isLoading"
                class="px-4 py-2 text-sm font-medium text-white rounded-md disabled:opacity-50"
                :class="isRegistrationOpen ? 'bg-red-600 hover:bg-red-700' : 'bg-green-600 hover:bg-green-700'"
              >
                {{ isRegistrationOpen ? '關閉選社' : '開啟選社' }}
              </button>
            </div>
          </div>
          
          <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
            <div>
              <p class="text-sm font-medium text-gray-600">分發進度</p>
              <p class="text-lg font-semibold text-gray-900">
                {{ Math.round((statistics?.assignment_completion_rate || 0) * 100) }}%
              </p>
            </div>
            <div class="text-right">
              <button
                @click="startAssignment"
                :disabled="isLoading"
                class="px-4 py-2 text-sm font-medium text-white bg-purple-600 rounded-md hover:bg-purple-700 disabled:opacity-50"
              >
                開始分發
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 重要時程 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">重要時程</h2>
        <div class="space-y-4">
          <div v-if="settings?.registration_start_date" class="flex items-center">
            <div class="w-3 h-3 bg-blue-600 rounded-full mr-3"></div>
            <div>
              <p class="text-sm font-medium text-gray-900">選社開始時間</p>
              <p class="text-sm text-gray-600">{{ formatDate(settings.registration_start_date) }}</p>
            </div>
          </div>
          
          <div v-if="settings?.registration_end_date" class="flex items-center">
            <div class="w-3 h-3 bg-red-600 rounded-full mr-3"></div>
            <div>
              <p class="text-sm font-medium text-gray-900">選社結束時間</p>
              <p class="text-sm text-gray-600">{{ formatDate(settings.registration_end_date) }}</p>
            </div>
          </div>
          
          <div v-if="settings?.assignment_date" class="flex items-center">
            <div class="w-3 h-3 bg-green-600 rounded-full mr-3"></div>
            <div>
              <p class="text-sm font-medium text-gray-900">分發時間</p>
              <p class="text-sm text-gray-600">{{ formatDate(settings.assignment_date) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 快速操作 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">快速操作</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <button
            @click="navigateTo('/school-admin/students')"
            class="flex items-center p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
          >
            <svg class="w-8 h-8 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
            </svg>
            <div class="text-left">
              <p class="font-medium text-gray-900">學生管理</p>
              <p class="text-sm text-gray-600">查看與管理學生資料</p>
            </div>
          </button>

          <button
            @click="navigateTo('/school-admin/clubs')"
            class="flex items-center p-4 bg-green-50 rounded-lg hover:bg-green-100 transition-colors"
          >
            <svg class="w-8 h-8 text-green-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            <div class="text-left">
              <p class="font-medium text-gray-900">社團管理</p>
              <p class="text-sm text-gray-600">管理社團與老師資料</p>
            </div>
          </button>

          <button
            @click="navigateTo('/school-admin/statistics')"
            class="flex items-center p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors"
          >
            <svg class="w-8 h-8 text-purple-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            <div class="text-left">
              <p class="font-medium text-gray-900">統計報表</p>
              <p class="text-sm text-gray-600">查看選社統計與分析</p>
            </div>
          </button>

          <button
            @click="navigateTo('/school-admin/settings')"
            class="flex items-center p-4 bg-yellow-50 rounded-lg hover:bg-yellow-100 transition-colors"
          >
            <svg class="w-8 h-8 text-yellow-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <div class="text-left">
              <p class="font-medium text-gray-900">系統設定</p>
              <p class="text-sm text-gray-600">調整系統參數與設定</p>
            </div>
          </button>

          <button
            @click="navigateTo('/school-admin/students/import')"
            class="flex items-center p-4 bg-indigo-50 rounded-lg hover:bg-indigo-100 transition-colors"
          >
            <svg class="w-8 h-8 text-indigo-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
            </svg>
            <div class="text-left">
              <p class="font-medium text-gray-900">批次匯入</p>
              <p class="text-sm text-gray-600">匯入學生或社團資料</p>
            </div>
          </button>

          <button
            @click="navigateTo('/school-admin/assignments')"
            class="flex items-center p-4 bg-red-50 rounded-lg hover:bg-red-100 transition-colors"
          >
            <svg class="w-8 h-8 text-red-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
            </svg>
            <div class="text-left">
              <p class="font-medium text-gray-900">分發管理</p>
              <p class="text-sm text-gray-600">管理學生分發結果</p>
            </div>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
import { useAuthStore } from '@/stores/auth'
import type { School, SchoolSetting, SchoolStatistics } from '@/types/school'

const router = useRouter()
const schoolStore = useSchoolStore()
const authStore = useAuthStore()

// 響應式狀態
const statistics = ref<SchoolStatistics | null>(null)

// 計算屬性
const isLoading = computed(() => schoolStore.isLoading)
const school = computed(() => schoolStore.current)
const settings = computed(() => schoolStore.settings)
const isRegistrationOpen = computed(() => settings.value?.is_registration_open || false)

// 方法
const refreshData = async () => {
  const currentSchool = authStore.currentSchool
  if (!currentSchool) return
  
  try {
    // 載入學校基本資訊
    await schoolStore.fetchSchool(currentSchool.id)
    
    // 載入設定
    await schoolStore.fetchSettings(currentSchool.id)
    
    // 載入統計資料
    await schoolStore.fetchStatistics(currentSchool.id)
    statistics.value = schoolStore.statistics
  } catch (error) {
    console.error('載入儀表板資料失敗:', error)
  }
}

const toggleRegistration = async () => {
  const currentSchool = authStore.currentSchool
  if (!currentSchool || !settings.value) return
  
  try {
    await schoolStore.updateSettings(currentSchool.id, {
      is_registration_open: !settings.value.is_registration_open
    })
    alert(`選社系統已${settings.value.is_registration_open ? '開啟' : '關閉'}`)
  } catch (error) {
    console.error('切換選社狀態失敗:', error)
    alert('操作失敗，請稍後再試')
  }
}

const startAssignment = async () => {
  const currentSchool = authStore.currentSchool
  if (!currentSchool) return
  
  if (!confirm('確定要開始執行學生分發嗎？此操作不可逆轉。')) {
    return
  }
  
  try {
    // 這裡需要調用分發 API
    // await assignmentApi.startAssignment(currentSchool.id)
    alert('分發程序已啟動')
    await refreshData()
  } catch (error) {
    console.error('啟動分發失敗:', error)
    alert('啟動分發失敗，請稍後再試')
  }
}

const navigateTo = (path: string) => {
  router.push(path)
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 生命週期
onMounted(() => {
  refreshData()
})
</script>
