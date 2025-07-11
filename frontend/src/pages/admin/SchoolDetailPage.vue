<template>
  <div class="p-8">
    <div class="mb-6">
      <button
        @click="goBack"
        class="flex items-center text-gray-600 hover:text-gray-800 mb-4"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        返回學校列表
      </button>
      <h1 class="text-3xl font-bold text-gray-900">學校詳情</h1>
    </div>

    <div v-if="isLoading" class="text-center py-8">
      <div class="text-lg">載入中...</div>
    </div>

    <div v-else-if="school" class="space-y-6">
      <!-- 學校基本資訊 -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">基本資訊</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">學校名稱</label>
            <p class="text-lg font-medium text-gray-900">{{ school.name }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">申請人姓名</label>
            <p class="text-lg text-gray-900">{{ school.applicant_name }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">申請人電子郵件</label>
            <p class="text-lg text-gray-900">{{ school.applicant_email }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">申請狀態</label>
            <span :class="getStatusClass(school.status)">
              {{ getStatusText(school.status) }}
            </span>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">建立時間</label>
            <p class="text-lg text-gray-900">{{ formatDate(school.created_at) }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">更新時間</label>
            <p class="text-lg text-gray-900">{{ formatDate(school.updated_at) }}</p>
          </div>
        </div>
      </div>

      <!-- 學校描述 -->
      <div v-if="school.description" class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">學校描述</h2>
        <p class="text-gray-900 leading-relaxed">{{ school.description }}</p>
      </div>

      <!-- 學校設定 -->
      <div v-if="settings" class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">系統設定</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">報名開放狀態</label>
            <span :class="settings.is_registration_open ? 'text-green-600' : 'text-red-600'">
              {{ settings.is_registration_open ? '開放中' : '已關閉' }}
            </span>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">最大志願數</label>
            <p class="text-lg text-gray-900">{{ settings.max_choices }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">允許修改志願</label>
            <span :class="settings.allow_change_after_submit ? 'text-green-600' : 'text-red-600'">
              {{ settings.allow_change_after_submit ? '允許' : '不允許' }}
            </span>
          </div>
          <div v-if="settings.registration_start_date">
            <label class="block text-sm font-medium text-gray-700 mb-2">報名開始時間</label>
            <p class="text-lg text-gray-900">{{ formatDate(settings.registration_start_date) }}</p>
          </div>
          <div v-if="settings.registration_end_date">
            <label class="block text-sm font-medium text-gray-700 mb-2">報名結束時間</label>
            <p class="text-lg text-gray-900">{{ formatDate(settings.registration_end_date) }}</p>
          </div>
          <div v-if="settings.assignment_date">
            <label class="block text-sm font-medium text-gray-700 mb-2">分發時間</label>
            <p class="text-lg text-gray-900">{{ formatDate(settings.assignment_date) }}</p>
          </div>
        </div>
      </div>

      <!-- 統計資料 -->
      <div v-if="statistics" class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">統計資料</h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div class="text-center">
            <div class="text-2xl font-bold text-blue-600">{{ statistics.total_students }}</div>
            <div class="text-sm text-gray-600">總學生數</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-green-600">{{ statistics.total_clubs }}</div>
            <div class="text-sm text-gray-600">總社團數</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-yellow-600">{{ statistics.total_selections }}</div>
            <div class="text-sm text-gray-600">總選課數</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-purple-600">{{ statistics.assigned_students }}</div>
            <div class="text-sm text-gray-600">已分發學生</div>
          </div>
        </div>
      </div>

      <!-- 操作區域 -->
      <div v-if="school.status === 'pending'" class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">審核操作</h2>
        <div class="flex space-x-4">
          <button
            @click="approveSchool"
            :disabled="isLoading"
            class="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50"
          >
            {{ isLoading ? '處理中...' : '核准申請' }}
          </button>
          <button
            @click="showRejectModal"
            :disabled="isLoading"
            class="px-6 py-3 bg-red-600 text-white rounded-md hover:bg-red-700 disabled:opacity-50"
          >
            拒絕申請
          </button>
        </div>
      </div>

      <!-- 管理動作 -->
      <div v-if="school.status === 'approved'" class="bg-white rounded-lg shadow p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">管理動作</h2>
        <div class="flex space-x-4">
          <button
            @click="viewSchoolSystem"
            class="px-6 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            進入學校系統
          </button>
          <button
            @click="refreshData"
            :disabled="isLoading"
            class="px-6 py-3 bg-gray-600 text-white rounded-md hover:bg-gray-700 disabled:opacity-50"
          >
            {{ isLoading ? '更新中...' : '重新整理' }}
          </button>
        </div>
      </div>
    </div>

    <div v-else class="text-center py-8">
      <div class="text-lg text-gray-600">找不到學校資訊</div>
    </div>

    <!-- 拒絕理由對話框 -->
    <div v-if="showRejectDialog" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3 text-center">
          <h3 class="text-lg leading-6 font-medium text-gray-900">拒絕學校申請</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500 mb-4">
              您確定要拒絕「{{ school?.name }}」的申請嗎？
            </p>
            <textarea
              v-model="rejectReason"
              placeholder="請輸入拒絕理由（選填）..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows="4"
            ></textarea>
          </div>
          <div class="items-center px-4 py-3">
            <button
              @click="confirmReject"
              :disabled="isLoading"
              class="px-4 py-2 bg-red-600 text-white text-base font-medium rounded-md w-full shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 disabled:opacity-50 mb-2"
            >
              {{ isLoading ? '處理中...' : '確認拒絕' }}
            </button>
            <button
              @click="hideRejectModal"
              :disabled="isLoading"
              class="px-4 py-2 bg-gray-300 text-gray-700 text-base font-medium rounded-md w-full shadow-sm hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-500 disabled:opacity-50"
            >
              取消
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
import type { School, SchoolSetting, SchoolStatistics } from '@/types/school'

const router = useRouter()
const route = useRoute()
const schoolStore = useSchoolStore()

// 響應式狀態
const school = ref<School | null>(null)
const settings = ref<SchoolSetting | null>(null)
const statistics = ref<SchoolStatistics | null>(null)
const showRejectDialog = ref(false)
const rejectReason = ref('')

// 計算屬性
const isLoading = computed(() => schoolStore.isLoading)
const schoolId = computed(() => parseInt(route.params.id as string))

// 方法
const refreshData = async () => {
  if (!schoolId.value) return
  
  try {
    // 載入學校基本資訊
    await schoolStore.fetchSchool(schoolId.value)
    school.value = schoolStore.current
    
    // 如果是已核准的學校，載入設定和統計資料
    if (school.value?.status === 'approved') {
      try {
        await schoolStore.fetchSettings(schoolId.value)
        settings.value = schoolStore.settings
      } catch (error) {
        console.log('學校設定尚未建立')
      }
      
      try {
        await schoolStore.fetchStatistics(schoolId.value)
        statistics.value = schoolStore.statistics
      } catch (error) {
        console.log('統計資料載入失敗')
      }
    }
  } catch (error) {
    console.error('載入學校資訊失敗:', error)
  }
}

const approveSchool = async () => {
  if (!schoolId.value) return
  
  try {
    await schoolStore.approveSchool(schoolId.value)
    await refreshData()
    alert('學校申請已核准')
  } catch (error) {
    console.error('核准學校失敗:', error)
    alert('核准失敗，請稍後再試')
  }
}

const showRejectModal = () => {
  rejectReason.value = ''
  showRejectDialog.value = true
}

const hideRejectModal = () => {
  showRejectDialog.value = false
  rejectReason.value = ''
}

const confirmReject = async () => {
  if (!schoolId.value) return
  
  try {
    await schoolStore.rejectSchool(schoolId.value, rejectReason.value)
    await refreshData()
    hideRejectModal()
    alert('學校申請已拒絕')
  } catch (error) {
    console.error('拒絕學校失敗:', error)
    alert('拒絕失敗，請稍後再試')
  }
}

const viewSchoolSystem = () => {
  // 跳轉到該學校的管理系統
  router.push(`/school/${schoolId.value}/admin`)
}

const goBack = () => {
  router.push('/admin/schools')
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getStatusClass = (status: string) => {
  switch (status) {
    case 'pending':
      return 'px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800'
    case 'approved':
      return 'px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-green-100 text-green-800'
    case 'rejected':
      return 'px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-red-100 text-red-800'
    default:
      return 'px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full bg-gray-100 text-gray-800'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'pending':
      return '待審核'
    case 'approved':
      return '已核准'
    case 'rejected':
      return '已拒絕'
    default:
      return '未知'
  }
}

// 生命週期
onMounted(() => {
  refreshData()
})
</script>