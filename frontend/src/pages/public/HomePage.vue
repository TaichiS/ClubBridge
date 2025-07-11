<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 導航列 -->
    <AuthNavigation />

    <!-- 主要內容 -->
    <div class="container mx-auto px-4 py-16">
      <!-- Hero Section -->
      <div class="text-center mb-16">
        <h1 class="text-5xl font-bold text-gray-900 mb-6">
          ClubBridge
        </h1>
        <p class="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
          現代化的多租戶跨校選社管理平台<br>
          簡化學校社團管理，優化學生選社體驗
        </p>
        
        <!-- 主要操作按鈕 -->
        <div class="flex flex-col sm:flex-row gap-4 justify-center" v-if="!isAuthenticated">
          <router-link
            to="/apply"
            class="btn-primary px-8 py-3 text-lg"
          >
            申請新學校
          </router-link>
          <router-link
            to="/auth/google"
            class="btn-secondary px-8 py-3 text-lg"
          >
            管理員登入
          </router-link>
        </div>

        <!-- 已登入用戶的儀表板鏈接 -->
        <div v-else class="space-y-4">
          <p class="text-lg text-gray-700">
            歡迎回來，{{ userDisplayName }}！
          </p>
          <button
            @click="goToDashboard"
            class="btn-primary px-8 py-3 text-lg"
          >
            前往{{ roleDisplayName }}儀表板
          </button>
        </div>
      </div>

      <!-- 功能特色 -->
      <div class="grid md:grid-cols-3 gap-8 mb-16">
        <div class="text-center p-6">
          <div class="w-16 h-16 bg-primary-100 rounded-lg flex items-center justify-center mx-auto mb-4">
            <AcademicCapIcon class="w-8 h-8 text-primary-600" />
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">多校管理</h3>
          <p class="text-gray-600">
            支援多個學校獨立管理，資料完全隔離，確保安全性
          </p>
        </div>

        <div class="text-center p-6">
          <div class="w-16 h-16 bg-primary-100 rounded-lg flex items-center justify-center mx-auto mb-4">
            <UserGroupIcon class="w-8 h-8 text-primary-600" />
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">智能分發</h3>
          <p class="text-gray-600">
            自動化社團分發系統，根據學生志願與社團限制進行最佳分配
          </p>
        </div>

        <div class="text-center p-6">
          <div class="w-16 h-16 bg-primary-100 rounded-lg flex items-center justify-center mx-auto mb-4">
            <ChartBarIcon class="w-8 h-8 text-primary-600" />
          </div>
          <h3 class="text-xl font-semibold text-gray-900 mb-2">即時統計</h3>
          <p class="text-gray-600">
            即時查看選社進度，各種統計報表一目了然
          </p>
        </div>
      </div>

      <!-- 學生登入區域 -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 max-w-2xl mx-auto">
        <h2 class="text-2xl font-bold text-gray-900 mb-4 text-center">
          學生登入
        </h2>
        <p class="text-gray-600 mb-6 text-center">
          請選擇您的學校進行登入
        </p>
        
        <!-- 學校選擇 -->
        <div class="mb-6">
          <label class="form-label">選擇學校</label>
          <select
            v-model="selectedSchool"
            class="form-input"
          >
            <option value="">請選擇學校</option>
            <option
              v-for="school in mockSchools"
              :key="school.id"
              :value="school.id"
            >
              {{ school.name }}
            </option>
          </select>
        </div>

        <div class="text-center">
          <button
            @click="goToStudentLogin"
            :disabled="!selectedSchool"
            class="btn-primary px-8 py-3 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            前往學生登入
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { AcademicCapIcon, UserGroupIcon, ChartBarIcon } from '@heroicons/vue/24/outline'
import AuthNavigation from '@/components/auth/AuthNavigation.vue'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { isAuthenticated, user, userRole, redirectAfterLogin } = useAuth()

// 模擬學校列表（實際應該從 API 獲取）
const mockSchools = ref([
  { id: 1, name: '台北市立第一高中' },
  { id: 2, name: '新北市立板橋高中' },
  { id: 3, name: '桃園市立武陵高中' }
])

const selectedSchool = ref<number | null>(null)

const userDisplayName = computed(() => {
  if (!user.value) return ''
  
  if ('name' in user.value) {
    return user.value.name
  }
  
  if ('email' in user.value) {
    return user.value.email?.split('@')[0] || '使用者'
  }
  
  return '使用者'
})

const roleDisplayName = computed(() => {
  switch (userRole.value) {
    case 'super_admin':
      return '超級管理員'
    case 'school_admin':
      return '學校管理員'
    case 'teacher':
      return '社團老師'
    case 'student':
      return '學生'
    default:
      return ''
  }
})

function goToStudentLogin() {
  if (selectedSchool.value) {
    router.push(`/schools/${selectedSchool.value}/student/login`)
  }
}

function goToDashboard() {
  redirectAfterLogin()
}
</script>