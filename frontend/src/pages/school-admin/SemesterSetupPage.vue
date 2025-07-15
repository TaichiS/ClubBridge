<template>
  <div class="p-4 sm:p-6 lg:p-8">
    <div class="max-w-4xl mx-auto">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">學期設定</h1>
        <p class="text-sm text-gray-500 mt-1">
          設定本學期的選社時間、結果公佈時間及上課日期。
        </p>
      </div>

      <div v-if="isLoading" class="text-center py-12">
        <p>資料載入中...</p>
      </div>

      <div v-else-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg mb-6">
        <p class="text-red-700">{{ error }}</p>
      </div>

      <form v-else-if="form" @submit.prevent="handleSubmit" class="card p-6 space-y-8">
        <!-- 選社時間設定 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="md:col-span-1">
            <h2 class="text-lg font-semibold text-gray-900">選社時間</h2>
            <p class="text-sm text-gray-500 mt-1">設定學生可以進行社團選擇的時間範圍。</p>
          </div>
          <div class="md:col-span-2 space-y-4">
            <div>
              <label class="form-label">選社開始時間 *</label>
              <input 
                v-model="form.club_selection_start_time" 
                type="datetime-local" 
                class="form-input" 
                required 
              />
            </div>
            <div>
              <label class="form-label">選社結束時間 *</label>
              <input 
                v-model="form.club_selection_end_time" 
                type="datetime-local" 
                class="form-input" 
                required 
              />
            </div>
          </div>
        </div>

        <!-- 結果公布時間設定 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 border-t pt-8">
          <div class="md:col-span-1">
            <h2 class="text-lg font-semibold text-gray-900">結果公布時間</h2>
            <p class="text-sm text-gray-500 mt-1">設定選社結果向學生公布的時間範圍。</p>
          </div>
          <div class="md:col-span-2 space-y-4">
            <div>
              <label class="form-label">結果公布開始時間 *</label>
              <input 
                v-model="form.result_announcement_start_time" 
                type="datetime-local" 
                class="form-input" 
                required 
              />
            </div>
            <div>
              <label class="form-label">結果公布結束時間 *</label>
              <input 
                v-model="form.result_announcement_end_time" 
                type="datetime-local" 
                class="form-input" 
                required 
              />
            </div>
          </div>
        </div>

        <!-- 上課日期設定 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 border-t pt-8">
          <div class="md:col-span-1">
            <h2 class="text-lg font-semibold text-gray-900">上課日期</h2>
            <p class="text-sm text-gray-500 mt-1">設定本學期的上課日期安排。</p>
          </div>
          <div class="md:col-span-2">
            <div>
              <label class="form-label">本學期上課日期</label>
              <textarea 
                v-model="form.semester_schedule" 
                class="form-input" 
                rows="6"
                placeholder="例如：
每週四 13:30-15:10
上課日期：
2024/09/05、2024/09/12、2024/09/19、2024/09/26
2024/10/03、2024/10/17、2024/10/24、2024/10/31
2024/11/07、2024/11/14、2024/11/21、2024/11/28
2024/12/05、2024/12/12、2024/12/19、2024/12/26
2025/01/02、2025/01/09、2025/01/16"
              ></textarea>
              <p class="text-xs text-gray-500 mt-1">
                請詳細列出本學期的上課時間與日期，學生和老師都會看到此資訊。
              </p>
            </div>
          </div>
        </div>

        <!-- 選社規則設定 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 border-t pt-8">
          <div class="md:col-span-1">
            <h2 class="text-lg font-semibold text-gray-900">選社規則</h2>
            <p class="text-sm text-gray-500 mt-1">設定學生選社的基本規則。</p>
          </div>
          <div class="md:col-span-2">
            <div>
              <label class="form-label">每位學生最少應選志願數 *</label>
              <input 
                v-model.number="form.min_required_choices" 
                type="number" 
                class="form-input" 
                min="1"
                max="20"
                required
                placeholder="例如：3"
              />
              <p class="text-xs text-gray-500 mt-1">
                設定學生至少必須選擇的志願數量。建議設定為3-5個志願以上。
              </p>
            </div>
          </div>
        </div>

        <!-- 提交按鈕 -->
        <div class="flex justify-end pt-6 border-t">
          <button type="submit" :disabled="isSubmitting" class="btn-primary">
            <span v-if="!isSubmitting">儲存設定</span>
            <span v-else>儲存中...</span>
          </button>
        </div>
      </form>
    </div>

    <!-- Toast 通知 -->
    <Toast
      v-if="showSuccessMessage"
      message="學期設定已成功儲存"
      type="success"
      @close="showSuccessMessage = false"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watchEffect } from 'vue'
import { useRoute } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
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
      club_selection_start_time: formatDateTimeLocal(schoolStore.current.club_selection_start_time),
      club_selection_end_time: formatDateTimeLocal(schoolStore.current.club_selection_end_time),
      result_announcement_start_time: formatDateTimeLocal(schoolStore.current.result_announcement_start_time),
      result_announcement_end_time: formatDateTimeLocal(schoolStore.current.result_announcement_end_time)
    }
  }
})

function formatDateTimeLocal(dateTime: string | null): string {
  if (!dateTime) return ''
  
  const date = new Date(dateTime)
  if (isNaN(date.getTime())) return ''
  
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  
  return `${year}-${month}-${day}T${hours}:${minutes}`
}

async function handleSubmit() {
  if (!form.value) return
  isSubmitting.value = true
  error.value = null
  showSuccessMessage.value = false

  try {
    await schoolStore.updateSchool(schoolId, form.value)
    
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