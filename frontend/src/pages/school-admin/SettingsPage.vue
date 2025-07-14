<template>
  <div class="p-4 sm:p-6 lg:p-8">
    <div class="max-w-4xl mx-auto">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">學校基本資料設定</h1>
        <p class="text-sm text-gray-500 mt-1">
          管理學校的基本聯絡資訊、網站、簡介等內容。
        </p>
      </div>

      <div v-if="isLoading" class="text-center py-12">
        <p>資料載入中...</p>
      </div>

      <div v-else-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg">
        <p class="text-red-700">{{ error }}</p>
      </div>

      <form v-else-if="form" @submit.prevent="handleSubmit" class="card p-6 space-y-8">
        <!-- 學校基本資訊 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="md:col-span-1">
            <h2 class="text-lg font-semibold text-gray-900">學校資訊</h2>
            <p class="text-sm text-gray-500 mt-1">學校的公開資訊，會顯示在相關頁面。</p>
          </div>
          <div class="md:col-span-2 space-y-4">
            <div>
              <label class="form-label">學校名稱 *</label>
              <input v-model="form.name" type="text" class="form-input" required />
            </div>
            <div>
              <label class="form-label">學校類型</label>
              <select v-model="form.school_type" class="form-input">
                <option value="elementary">國小</option>
                <option value="junior_high">國中</option>
                <option value="senior_high">高中</option>
                <option value="vocational">高職</option>
                <option value="university">大學</option>
              </select>
            </div>
            <div>
              <label class="form-label">學校地址</label>
              <input v-model="form.address" type="text" class="form-input" />
            </div>
            <div>
              <label class="form-label">學校網站</label>
              <input v-model="form.website" type="url" class="form-input" />
            </div>
            <div>
              <label class="form-label">學校簡介</label>
              <textarea v-model="form.description" class="form-input" rows="4"></textarea>
            </div>
          </div>
        </div>

        <!-- 聯絡人資訊 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 border-t pt-8">
          <div class="md:col-span-1">
            <h2 class="text-lg font-semibold text-gray-900">聯絡人資訊</h2>
            <p class="text-sm text-gray-500 mt-1">系統管理與緊急聯絡用途。</p>
          </div>
          <div class="md:col-span-2 space-y-4">
            <div>
              <label class="form-label">聯絡人姓名 *</label>
              <input v-model="form.contact_name" type="text" class="form-input" required />
            </div>
            <div>
              <label class="form-label">聯絡人職稱</label>
              <input v-model="form.contact_title" type="text" class="form-input" />
            </div>
            <div>
              <label class="form-label">聯絡信箱 *</label>
              <input v-model="form.contact_email" type="email" class="form-input" required />
            </div>
            <div>
              <label class="form-label">聯絡電話</label>
              <input v-model="form.contact_phone" type="tel" class="form-input" />
            </div>
          </div>
        </div>

        <!-- 提交按鈕 -->
        <div class="flex justify-end pt-6 border-t">
          <button type="submit" :disabled="isSubmitting" class="btn-primary">
            <span v-if="!isSubmitting">儲存變更</span>
            <span v-else>儲存中...</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watchEffect } from 'vue'
import { useRoute } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
import type { School } from '@/types/school'

const route = useRoute()
const schoolStore = useSchoolStore()

const schoolId = Number(route.params.schoolId)

const form = ref<Partial<School> | null>(null)
const isLoading = ref(true)
const isSubmitting = ref(false)
const error = ref<string | null>(null)

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
    form.value = { ...schoolStore.current }
  }
})

async function handleSubmit() {
  if (!form.value) return
  isSubmitting.value = true
  error.value = null

  try {
    await schoolStore.updateSchool(schoolId, form.value)
    // 可以加入一個成功提示，例如 toast message
    alert('學校資料更新成功！')
  } catch (err) {
    error.value = '更新失敗，請檢查您的輸入或稍後再試。'
    console.error(err)
  } finally {
    isSubmitting.value = false
  }
}
</script>
