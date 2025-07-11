<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 導航列 -->
    <AuthNavigation />

    <div class="container mx-auto px-4 py-8">
      <div class="max-w-2xl mx-auto">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-4">
            申請新學校加入 ClubBridge
          </h1>
          <p class="text-gray-600">
            填寫以下資訊，我們會盡快審核您的申請
          </p>
        </div>

        <div class="card">
          <!-- 成功訊息 -->
          <div v-if="isSuccess" class="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
            <div class="flex items-start">
              <CheckCircleIcon class="w-5 h-5 text-green-500 mt-0.5 mr-3" />
              <div>
                <h3 class="text-sm font-medium text-green-800">申請已提交</h3>
                <p class="text-sm text-green-700 mt-1">
                  感謝您的申請！我們已收到您的學校申請，將在 3-5 個工作天內完成審核。
                  審核結果將透過 Email 通知您。
                </p>
                <div class="mt-4">
                  <router-link
                    to="/"
                    class="text-sm text-green-600 hover:text-green-800 underline"
                  >
                    返回首頁
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- 申請表單 -->
          <form v-else @submit.prevent="handleSubmit" class="space-y-6">
            <!-- 學校基本資訊 -->
            <div>
              <h2 class="text-lg font-semibold text-gray-900 mb-4">學校基本資訊</h2>
              
              <div class="space-y-4">
                <div>
                  <label class="form-label">學校名稱 *</label>
                  <input
                    v-model="form.name"
                    type="text"
                    class="form-input"
                    placeholder="請輸入完整的學校名稱"
                    required
                    :disabled="isLoading"
                  />
                </div>

                <div>
                  <label class="form-label">學校類型</label>
                  <select
                    v-model="form.school_type"
                    class="form-input"
                    :disabled="isLoading"
                  >
                    <option value="">請選擇學校類型</option>
                    <option value="elementary">國小</option>
                    <option value="junior_high">國中</option>
                    <option value="senior_high">高中</option>
                    <option value="vocational">高職</option>
                    <option value="university">大學</option>
                  </select>
                </div>

                <div>
                  <label class="form-label">學校地址</label>
                  <input
                    v-model="form.address"
                    type="text"
                    class="form-input"
                    placeholder="請輸入學校地址"
                    :disabled="isLoading"
                  />
                </div>

                <div>
                  <label class="form-label">學校網站</label>
                  <input
                    v-model="form.website"
                    type="url"
                    class="form-input"
                    placeholder="https://example.edu.tw"
                    :disabled="isLoading"
                  />
                </div>

                <div>
                  <label class="form-label">學校簡介</label>
                  <textarea
                    v-model="form.description"
                    class="form-input"
                    rows="4"
                    placeholder="請簡單介紹學校特色或背景"
                    :disabled="isLoading"
                  ></textarea>
                </div>
              </div>
            </div>

            <!-- 聯絡人資訊 -->
            <div>
              <h2 class="text-lg font-semibold text-gray-900 mb-4">聯絡人資訊</h2>
              
              <div class="space-y-4">
                <div>
                  <label class="form-label">聯絡人姓名 *</label>
                  <input
                    v-model="form.contact_name"
                    type="text"
                    class="form-input"
                    placeholder="請輸入聯絡人姓名"
                    required
                    :disabled="isLoading"
                  />
                </div>

                <div>
                  <label class="form-label">聯絡人職稱</label>
                  <input
                    v-model="form.contact_title"
                    type="text"
                    class="form-input"
                    placeholder="例：教務主任、資訊組長"
                    :disabled="isLoading"
                  />
                </div>

                <div>
                  <label class="form-label">聯絡信箱 *</label>
                  <input
                    v-model="form.contact_email"
                    type="email"
                    class="form-input"
                    placeholder="請輸入聯絡信箱"
                    required
                    :disabled="isLoading"
                  />
                  <p class="text-sm text-gray-500 mt-1">
                    此信箱將作為系統管理員帳號，請確保可正常收發郵件
                  </p>
                </div>

                <div>
                  <label class="form-label">聯絡電話</label>
                  <input
                    v-model="form.contact_phone"
                    type="tel"
                    class="form-input"
                    placeholder="請輸入聯絡電話"
                    :disabled="isLoading"
                  />
                </div>
              </div>
            </div>

            <!-- 使用需求 -->
            <div>
              <h2 class="text-lg font-semibold text-gray-900 mb-4">使用需求</h2>
              
              <div class="space-y-4">
                <div>
                  <label class="form-label">預估學生人數</label>
                  <select
                    v-model="form.student_count"
                    class="form-input"
                    :disabled="isLoading"
                  >
                    <option value="">請選擇預估學生人數</option>
                    <option value="100">100 人以下</option>
                    <option value="500">100-500 人</option>
                    <option value="1000">500-1000 人</option>
                    <option value="2000">1000-2000 人</option>
                    <option value="2000+">2000 人以上</option>
                  </select>
                </div>

                <div>
                  <label class="form-label">預估社團數量</label>
                  <select
                    v-model="form.club_count"
                    class="form-input"
                    :disabled="isLoading"
                  >
                    <option value="">請選擇預估社團數量</option>
                    <option value="10">10 個以下</option>
                    <option value="30">10-30 個</option>
                    <option value="50">30-50 個</option>
                    <option value="100">50-100 個</option>
                    <option value="100+">100 個以上</option>
                  </select>
                </div>

                <div>
                  <label class="form-label">預計使用時間</label>
                  <input
                    v-model="form.expected_start_date"
                    type="date"
                    class="form-input"
                    :disabled="isLoading"
                  />
                </div>

                <div>
                  <label class="form-label">其他需求或備註</label>
                  <textarea
                    v-model="form.notes"
                    class="form-input"
                    rows="3"
                    placeholder="如有其他特殊需求或想了解的功能，請在此說明"
                    :disabled="isLoading"
                  ></textarea>
                </div>
              </div>
            </div>

            <!-- 錯誤訊息 -->
            <div v-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg">
              <div class="flex items-start">
                <ExclamationTriangleIcon class="w-5 h-5 text-red-500 mt-0.5 mr-3" />
                <div>
                  <h3 class="text-sm font-medium text-red-800">申請失敗</h3>
                  <p class="text-sm text-red-700 mt-1">{{ error }}</p>
                  <button
                    type="button"
                    @click="clearError"
                    class="mt-2 text-sm text-red-600 hover:text-red-800 underline"
                  >
                    關閉
                  </button>
                </div>
              </div>
            </div>

            <!-- 提交按鈕 -->
            <div class="flex flex-col sm:flex-row gap-4">
              <button
                type="submit"
                :disabled="isLoading || !isFormValid"
                class="btn-primary flex-1"
              >
                <span v-if="!isLoading">提交申請</span>
                <span v-else>申請中...</span>
              </button>
              
              <router-link
                to="/"
                class="btn-secondary flex-1 text-center"
              >
                取消
              </router-link>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { CheckCircleIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import AuthNavigation from '@/components/auth/AuthNavigation.vue'
import { useSchoolStore } from '@/stores/school'

const schoolStore = useSchoolStore()

const isLoading = ref(false)
const isSuccess = ref(false)
const error = ref<string | null>(null)

const form = ref({
  name: '',
  school_type: '',
  address: '',
  website: '',
  description: '',
  contact_name: '',
  contact_title: '',
  contact_email: '',
  contact_phone: '',
  student_count: '',
  club_count: '',
  expected_start_date: '',
  notes: ''
})

const isFormValid = computed(() => {
  return form.value.name.trim() !== '' &&
         form.value.contact_name.trim() !== '' &&
         form.value.contact_email.trim() !== ''
})

async function handleSubmit() {
  if (!isFormValid.value) return

  isLoading.value = true
  error.value = null

  try {
    await schoolStore.applySchool({
      name: form.value.name.trim(),
      description: form.value.description,
      contact_email: form.value.contact_email.trim()
    })
    
    isSuccess.value = true
  } catch (err) {
    console.error('School application failed:', err)
    error.value = err instanceof Error ? err.message : '申請失敗，請稍後再試'
  } finally {
    isLoading.value = false
  }
}

function clearError() {
  error.value = null
}
</script>