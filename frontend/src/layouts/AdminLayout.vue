<template>
  <div class="min-h-screen bg-gray-50">
    <div class="flex">
      <!-- 側邊導航欄 -->
      <nav class="w-64 bg-white shadow-lg border-r border-gray-200">
        <div class="p-6">
          <div class="flex items-center space-x-3">
            <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <i class="fas fa-crown text-white text-sm"></i>
            </div>
            <h2 class="text-xl font-bold text-gray-800">超級管理員</h2>
          </div>
        </div>

        <div class="px-4 pb-4">
          <!-- 用戶資訊 -->
          <div class="bg-gray-50 rounded-lg p-4 mb-6">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white font-semibold">
                {{ userStore.user?.name?.charAt(0).toUpperCase() }}
              </div>
              <div>
                <p class="font-medium text-gray-900 text-sm">{{ userStore.user?.name }}</p>
                <p class="text-xs text-gray-500">{{ userStore.user?.email }}</p>
              </div>
            </div>
          </div>

          <!-- 導航選單 -->
          <ul class="space-y-2">
            <li>
              <router-link 
                to="/admin" 
                class="flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors"
                :class="$route.name === 'admin-dashboard' ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-600' : 'text-gray-700 hover:bg-gray-50'"
              >
                <i class="fas fa-tachometer-alt w-5"></i>
                <span class="font-medium">控制台</span>
              </router-link>
            </li>
            <li>
              <router-link 
                to="/admin/schools" 
                class="flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors"
                :class="String($route.name).startsWith('admin-school') ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-600' : 'text-gray-700 hover:bg-gray-50'"
              >
                <i class="fas fa-school w-5"></i>
                <span class="font-medium">學校管理</span>
                <span v-if="pendingSchoolsCount > 0" class="ml-auto bg-red-500 text-white text-xs rounded-full px-2 py-1">
                  {{ pendingSchoolsCount }}
                </span>
              </router-link>
            </li>
            <li>
              <router-link 
                to="/admin/users" 
                class="flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors"
                :class="$route.name === 'admin-users' ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-600' : 'text-gray-700 hover:bg-gray-50'"
              >
                <i class="fas fa-users w-5"></i>
                <span class="font-medium">用戶管理</span>
              </router-link>
            </li>
          </ul>

          <!-- 系統資訊 -->
          <div class="mt-8 pt-6 border-t border-gray-200">
            <div class="text-xs text-gray-500 space-y-1">
              <p>系統版本：v1.0.0</p>
              <p>最後更新：{{ formatDate(new Date()) }}</p>
            </div>
          </div>

          <!-- 登出按鈕 -->
          <div class="mt-6">
            <button 
              @click="handleLogout"
              class="w-full flex items-center justify-center space-x-2 px-4 py-3 bg-red-50 text-red-700 rounded-lg hover:bg-red-100 transition-colors"
            >
              <i class="fas fa-sign-out-alt"></i>
              <span class="font-medium">登出</span>
            </button>
          </div>
        </div>
      </nav>

      <!-- 主要內容區域 -->
      <main class="flex-1 overflow-hidden">
        <!-- 頂部工具欄 -->
        <header class="bg-white shadow-sm border-b border-gray-200">
          <div class="px-6 py-4">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-2xl font-bold text-gray-900">{{ pageTitle }}</h1>
                <p class="text-sm text-gray-500 mt-1">{{ pageDescription }}</p>
              </div>
              <div class="flex items-center space-x-4">
                <!-- 通知圖示 -->
                <button class="relative p-2 text-gray-400 hover:text-gray-600">
                  <i class="fas fa-bell text-lg"></i>
                  <span v-if="notificationCount > 0" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                    {{ notificationCount }}
                  </span>
                </button>
                <!-- 快速操作 -->
                <button class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                  <i class="fas fa-plus mr-2"></i>
                  快速操作
                </button>
              </div>
            </div>
          </div>
        </header>

        <!-- 頁面內容 -->
        <div class="p-6 overflow-y-auto h-[calc(100vh-80px)]">
          <router-view />
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const userStore = useAuthStore()

// 待審核學校數量
const pendingSchoolsCount = ref(0)
// 通知數量
const notificationCount = ref(3)

// 頁面標題和描述
const pageTitle = computed(() => {
  switch (route.name) {
    case 'admin-dashboard': return '控制台'
    case 'admin-schools': return '學校管理'
    case 'admin-school-detail': return '學校詳情'
    case 'admin-users': return '用戶管理'
    default: return '管理員後台'
  }
})

const pageDescription = computed(() => {
  switch (route.name) {
    case 'admin-dashboard': return '系統概覽和快速操作'
    case 'admin-schools': return '管理所有學校申請和審核'
    case 'admin-school-detail': return '查看和編輯學校詳細資訊'
    case 'admin-users': return '管理系統用戶和權限'
    default: return '系統管理和維護'
  }
})

// 格式化日期
const formatDate = (date: Date) => {
  return date.toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 登出處理
const handleLogout = async () => {
  try {
    await userStore.logout()
    router.push('/')
  } catch (error) {
    console.error('登出失敗:', error)
  }
}

// 載入待審核學校數量
const loadPendingSchools = async () => {
  try {
    // TODO: 實作 API 呼叫
    pendingSchoolsCount.value = 2 // 模擬數據
  } catch (error) {
    console.error('載入待審核學校失敗:', error)
  }
}

onMounted(() => {
  loadPendingSchools()
})
</script>
