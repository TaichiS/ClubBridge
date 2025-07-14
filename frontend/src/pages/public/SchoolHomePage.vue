<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="max-w-md w-full">
      <div class="card text-center">
        <div v-if="isLoading" class="py-12">
          <p>正在載入學校資訊...</p>
        </div>
        <div v-else-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-red-700">{{ error }}</p>
        </div>
        <div v-else-if="school" class="space-y-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">{{ school.name }}</h1>
            <p class="text-gray-500 mt-2">歡迎來到本校選社系統</p>
          </div>
          
          <div class="space-y-4">
            <router-link 
              :to="`/schools/${schoolId}/student/login`" 
              class="btn-primary w-full block"
            >
              我是學生
            </router-link>
            
            <button 
              @click="handleStaffLogin"
              class="btn-secondary w-full block"
            >
              我是教職員
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
import { useAuthStore } from '@/stores/auth'
import type { School } from '@/types/school'

const route = useRoute()
const router = useRouter()
const schoolStore = useSchoolStore()
const authStore = useAuthStore()

const schoolId = computed(() => Number(route.params.schoolId))
const school = ref<School | null>(null)
const isLoading = ref(true)
const error = ref<string | null>(null)

onMounted(async () => {
  try {
    await schoolStore.fetchPublicSchool(schoolId.value)
    school.value = schoolStore.current
  } catch (err) {
    error.value = '無法載入學校資訊，請確認網址是否正確。'
    console.error(err)
  } finally {
    isLoading.value = false
  }
})

function handleStaffLogin() {
  // 將學校 ID ��起來，以便 Google 登入後可以導向正確的學校後台
  authStore.setLoginRedirectSchool(schoolId.value)
  // 導向 Google 登入流程
  router.push('/auth/google')
}
</script>
