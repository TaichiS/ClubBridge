<template>
  <div class="p-4 sm:p-6 lg:p-8">
    <div class="max-w-6xl mx-auto">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">公告管理</h1>
        <p class="text-sm text-gray-500 mt-1">
          管理學校的一般公告和置頂公告內容。支援 Markdown 語法進行排版。
        </p>
      </div>

      <div v-if="isLoading" class="text-center py-12">
        <p>資料載入中...</p>
      </div>

      <div v-else-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg mb-6">
        <p class="text-red-700">{{ error }}</p>
      </div>

      <form v-else-if="form" @submit.prevent="handleSubmit" class="space-y-8">
        <!-- 置頂公告 -->
        <div class="card p-6">
          <div class="mb-6">
            <h2 class="text-lg font-semibold text-gray-900 flex items-center">
              <svg class="w-5 h-5 mr-2 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
              置頂公告
            </h2>
            <p class="text-sm text-gray-500 mt-1">
              重要公告內容，會在學校首頁頂部顯示。留空則不顯示置頂公告。
            </p>
          </div>
          
          <MarkdownEditor
            v-model="form.top_announcement"
            placeholder="輸入置頂公告內容（支援 Markdown 語法）..."
            :rows="8"
          />
        </div>

        <!-- 一般公告 -->
        <div class="card p-6">
          <div class="mb-6">
            <h2 class="text-lg font-semibold text-gray-900 flex items-center">
              <svg class="w-5 h-5 mr-2 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
              </svg>
              一般公告
            </h2>
            <p class="text-sm text-gray-500 mt-1">
              學校的一般公告內容，會在學校首頁的公告區域顯示。
            </p>
          </div>
          
          <MarkdownEditor
            v-model="form.announcement"
            placeholder="輸入一般公告內容（支援 Markdown 語法）..."
            :rows="12"
          />
        </div>

        <!-- 提交按鈕 -->
        <div class="flex justify-end pt-6 border-t">
          <button type="submit" :disabled="isSubmitting" class="btn-primary">
            <span v-if="!isSubmitting">儲存公告</span>
            <span v-else>儲存中...</span>
          </button>
        </div>
      </form>
    </div>

    <!-- Toast 通知 -->
    <Toast
      v-if="showSuccessMessage"
      message="公告已成功儲存"
      type="success"
      @close="showSuccessMessage = false"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watchEffect } from 'vue'
import { useRoute } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
import MarkdownEditor from '@/components/MarkdownEditor.vue'
import Toast from '@/components/Toast.vue'
import type { School } from '@/types/school'

const route = useRoute()
const schoolStore = useSchoolStore()

const schoolId = Number(route.params.schoolId)

const form = ref<Partial<School> | null>(null)
const isLoading = ref(true)
const isSubmitting = ref(false)
const error = ref<string | null>(null)
const showSuccessMessage = ref(false)

onMounted(async () => {
  if (schoolId) {
    try {
      await schoolStore.fetchSchool(schoolId)
    } catch (err) {
      error.value = '無法載入學校資料，請稍後再試。'
      console.error(err)
    } finally {
      isLoading.value = false
    }
  }
})

watchEffect(() => {
  if (schoolStore.current && schoolStore.current.id === schoolId) {
    form.value = { 
      ...schoolStore.current,
      announcement: schoolStore.current.announcement || '',
      top_announcement: schoolStore.current.top_announcement || ''
    }
  }
})

async function handleSubmit() {
  if (!form.value) return
  isSubmitting.value = true
  error.value = null
  showSuccessMessage.value = false

  try {
    await schoolStore.updateSchool(schoolId, {
      announcement: form.value.announcement,
      top_announcement: form.value.top_announcement
    })
    
    // 顯示成功訊息
    showSuccessMessage.value = true
    
  } catch (err) {
    error.value = '更新失敗，請檢查您的輸入或稍後再試。'
    console.error(err)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
.card {
  @apply bg-white border border-gray-200 rounded-lg shadow-sm;
}

.btn-primary {
  @apply bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md disabled:opacity-50 disabled:cursor-not-allowed transition-colors;
}

.form-input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent;
}
</style>