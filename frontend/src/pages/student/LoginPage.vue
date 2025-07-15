<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="max-w-md w-full">
      <div class="card">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            學生登入
          </h1>
          <p class="text-gray-600">
            請輸入學號和身分證字號登入
          </p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-6">
          <!-- 學號 -->
          <div>
            <label class="form-label">學號</label>
            <input
              v-model="form.student_number"
              type="text"
              class="form-input"
              placeholder="請輸入學號"
              required
              :disabled="isLoading"
            />
          </div>

          <!-- 身分證字號 -->
          <div>
            <label class="form-label">身分證字號</label>
            <input
              v-model="form.id_number"
              type="text"
              class="form-input"
              placeholder="請輸入身分證字號"
              maxlength="10"
              required
              :disabled="isLoading"
              @input="formatIdNumber"
            />
          </div>

          <!-- 錯誤訊息 -->
          <div v-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg">
            <p class="text-sm text-red-600">{{ error }}</p>
            <button
              type="button"
              @click="clearError"
              class="mt-2 text-sm text-red-500 hover:text-red-700 underline"
            >
              關閉
            </button>
          </div>

          <!-- 登入按鈕 -->
          <button
            type="submit"
            :disabled="isLoading || !isFormValid"
            class="btn-primary w-full"
          >
            <span v-if="!isLoading">登入</span>
            <span v-else>登入中...</span>
          </button>
        </form>

        <!-- 說明 -->
        <div class="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h3 class="text-sm font-medium text-blue-800 mb-2">登入說明</h3>
          <ul class="text-sm text-blue-700 space-y-1">
            <li>• 學號：請輸入學校提供的學號</li>
            <li>• 身分證字號：請輸入完整的身分證字號（含英文字母）</li>
            <li>• 如有登入問題，請洽詢學校管理員</li>
          </ul>
        </div>

        <!-- 返回 -->
        <div class="mt-6 text-center">
          <router-link
            :to="`/schools/${schoolId}`"
            class="text-gray-600 hover:text-gray-800 transition-colors duration-200"
          >
            ← 返回
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import type { LoginCredentials } from '@/types/auth'

const route = useRoute()
const { isLoading, error, loginAsStudent, clearError, isAuthenticated, redirectAfterLogin } = useAuth()

const schoolId = computed(() => route.params.schoolId as string)

const form = ref<LoginCredentials>({
  student_number: '',
  id_number: ''
})

const isFormValid = computed(() => {
  return form.value.student_number?.trim() !== '' && 
         form.value.id_number?.trim() !== '' &&
         (form.value.id_number?.length || 0) >= 8
})

async function handleLogin() {
  if (!isFormValid.value) return

  try {
    await loginAsStudent({
      student_number: form.value.student_number?.trim(),
      id_number: form.value.id_number?.trim().toUpperCase(),
      school_id: parseInt(schoolId.value)
    })
  } catch (err) {
    console.error('Student login failed:', err)
  }
}

// 格式化身分證字號（自動轉大寫）
function formatIdNumber() {
  if (form.value.id_number) {
    form.value.id_number = form.value.id_number.toUpperCase()
  }
}

onMounted(() => {
  clearError()
  
  // 如果已經登入，直接跳轉
  if (isAuthenticated.value) {
    redirectAfterLogin()
  }
})
</script>
