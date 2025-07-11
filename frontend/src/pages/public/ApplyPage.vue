<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-md mx-auto">
        <h1 class="text-3xl font-bold text-center text-gray-900 mb-8">
          申請新學校
        </h1>
        <div class="card">
          <form @submit.prevent="handleSubmit">
            <div class="mb-4">
              <label class="form-label">學校名稱</label>
              <input
                v-model="form.name"
                type="text"
                class="form-input"
                required
              />
            </div>
            <div class="mb-4">
              <label class="form-label">學校描述</label>
              <textarea
                v-model="form.description"
                class="form-input"
                rows="3"
              ></textarea>
            </div>
            <div class="mb-6">
              <label class="form-label">聯絡信箱</label>
              <input
                v-model="form.contact_email"
                type="email"
                class="form-input"
                required
              />
            </div>
            <button
              type="submit"
              class="btn-primary w-full"
              :disabled="isLoading"
            >
              {{ isLoading ? '申請中...' : '提交申請' }}
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const form = ref({
  name: '',
  description: '',
  contact_email: ''
})

const isLoading = ref(false)

async function handleSubmit() {
  isLoading.value = true
  try {
    // TODO: 實作申請邏輯
    console.log('申請表單:', form.value)
  } catch (error) {
    console.error('申請失敗:', error)
  } finally {
    isLoading.value = false
  }
}
</script>