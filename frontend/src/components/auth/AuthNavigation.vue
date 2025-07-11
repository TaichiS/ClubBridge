<template>
  <div class="bg-white border-b border-gray-200">
    <div class="container mx-auto px-4">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <router-link
          to="/"
          class="flex items-center space-x-2"
        >
          <div class="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold text-sm">CB</span>
          </div>
          <span class="text-xl font-bold text-gray-900">ClubBridge</span>
        </router-link>

        <!-- 導航內容 -->
        <div class="flex items-center space-x-4">
          <!-- 未登入狀態 -->
          <template v-if="!isAuthenticated">
            <router-link
              to="/auth/google"
              class="text-gray-600 hover:text-gray-800 transition-colors duration-200"
            >
              管理員登入
            </router-link>
            <div class="text-gray-300">|</div>
            <router-link
              to="/apply"
              class="btn-primary"
            >
              申請新學校
            </router-link>
          </template>

          <!-- 已登入狀態 -->
          <template v-else>
            <!-- 使用者資訊 -->
            <div class="flex items-center space-x-3">
              <div class="text-sm">
                <p class="text-gray-900 font-medium">{{ userDisplayName }}</p>
                <p class="text-gray-500">{{ roleDisplayName }}</p>
              </div>
              
              <!-- 使用者頭像 -->
              <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                <span class="text-gray-600 font-medium text-sm">
                  {{ userInitials }}
                </span>
              </div>

              <!-- 登出按鈕 -->
              <button
                @click="handleLogout"
                :disabled="isLoading"
                class="text-gray-600 hover:text-gray-800 transition-colors duration-200 disabled:opacity-50"
              >
                <LogoutIcon class="w-5 h-5" />
              </button>
            </div>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { ArrowRightEndOnRectangleIcon as LogoutIcon } from '@heroicons/vue/24/outline'
import { useAuth } from '@/composables/useAuth'

const { isAuthenticated, user, userRole, isLoading, logout } = useAuth()

const userDisplayName = computed(() => {
  if (!user.value) return ''
  
  if ('name' in user.value) {
    return user.value.name
  }
  
  if ('email' in user.value) {
    return user.value.email
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

const userInitials = computed(() => {
  const name = userDisplayName.value
  if (!name) return '?'
  
  if (name.includes('@')) {
    // 如果是 email，取第一個字母
    return name.charAt(0).toUpperCase()
  }
  
  // 如果是中文姓名，取最後一個字
  if (/[\u4e00-\u9fa5]/.test(name)) {
    return name.charAt(name.length - 1)
  }
  
  // 英文姓名取首字母
  const parts = name.split(' ')
  if (parts.length >= 2) {
    return (parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase()
  }
  
  return name.charAt(0).toUpperCase()
})

async function handleLogout() {
  try {
    await logout()
  } catch (error) {
    console.error('Logout failed:', error)
  }
}
</script>