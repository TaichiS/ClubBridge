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
      <!-- 申請狀態卡片 -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 bg-gray-50 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold text-gray-900">{{ school.name }}</h2>
            <span :class="getStatusClass(school.status)">
              {{ getStatusText(school.status) }}
            </span>
          </div>
          <p class="text-sm text-gray-600 mt-1">學校 ID: {{ school.id }}</p>
        </div>
        <div class="px-6 py-4">
          <div class="flex items-center space-x-6 text-sm text-gray-600">
            <div class="flex items-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
              申請時間：{{ formatDate(school.created_at) }}
            </div>
            <div v-if="school.updated_at !== school.created_at" class="flex items-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
              最後更新：{{ formatDate(school.updated_at) }}
            </div>
          </div>
        </div>
      </div>

      <!-- 學校基本資訊 -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center mb-4">
          <svg class="w-5 h-5 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-2m-14 0h2m0 0h2m-6 0v-5a2 2 0 012-2h2a2 2 0 012 2v5"></path>
          </svg>
          <h2 class="text-xl font-semibold text-gray-900">學校基本資訊</h2>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="form-label">學校名稱</label>
            <p class="text-lg font-medium text-gray-900">{{ school.name }}</p>
          </div>
          <div v-if="school.school_type">
            <label class="form-label">學校類型</label>
            <p class="text-lg text-gray-900">{{ getSchoolTypeText(school.school_type) }}</p>
          </div>
          <div v-if="school.address">
            <label class="form-label">學校地址</label>
            <p class="text-lg text-gray-900">{{ school.address }}</p>
          </div>
          <div v-if="school.website">
            <label class="form-label">學校網站</label>
            <a :href="school.website" target="_blank" class="text-lg text-blue-600 hover:text-blue-800 underline">
              {{ school.website }}
            </a>
          </div>
        </div>
      </div>

      <!-- 學校描述 -->
      <div v-if="school.description" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center mb-4">
          <svg class="w-5 h-5 text-green-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
          </svg>
          <h2 class="text-xl font-semibold text-gray-900">學校簡介</h2>
        </div>
        <div class="bg-gray-50 rounded-lg p-4">
          <p class="text-gray-900 leading-relaxed whitespace-pre-wrap">{{ school.description }}</p>
        </div>
      </div>

      <!-- 聯絡人資訊 -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center mb-4">
          <svg class="w-5 h-5 text-purple-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
          </svg>
          <h2 class="text-xl font-semibold text-gray-900">聯絡人資訊</h2>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="form-label">聯絡人姓名</label>
            <p class="text-lg font-medium text-gray-900">{{ school.contact_name || school.applicant_name || '未提供' }}</p>
          </div>
          <div v-if="school.contact_title">
            <label class="form-label">聯絡人職稱</label>
            <p class="text-lg text-gray-900">{{ school.contact_title }}</p>
          </div>
          <div>
            <label class="form-label">聯絡信箱</label>
            <a :href="`mailto:${school.contact_email || school.applicant_email}`" 
               class="text-lg text-blue-600 hover:text-blue-800 underline">
              {{ school.contact_email || school.applicant_email }}
            </a>
          </div>
          <div v-if="school.contact_phone">
            <label class="form-label">聯絡電話</label>
            <a :href="`tel:${school.contact_phone}`" class="text-lg text-blue-600 hover:text-blue-800">
              {{ school.contact_phone }}
            </a>
          </div>
        </div>
      </div>

      <!-- 使用需求 -->
      <div v-if="hasUsageRequirements" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center mb-4">
          <svg class="w-5 h-5 text-orange-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
          </svg>
          <h2 class="text-xl font-semibold text-gray-900">使用需求</h2>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-if="school.student_count">
            <label class="form-label">預估學生人數</label>
            <p class="text-lg text-gray-900">{{ getStudentCountText(school.student_count) }}</p>
          </div>
          <div v-if="school.club_count">
            <label class="form-label">預估社團數量</label>
            <p class="text-lg text-gray-900">{{ getClubCountText(school.club_count) }}</p>
          </div>
          <div v-if="school.expected_start_date">
            <label class="form-label">預計使用時間</label>
            <p class="text-lg text-gray-900">{{ formatDate(school.expected_start_date) }}</p>
          </div>
        </div>
        <div v-if="school.notes" class="mt-6">
          <label class="form-label">其他需求或備註</label>
          <div class="bg-gray-50 rounded-lg p-4">
            <p class="text-gray-900 leading-relaxed whitespace-pre-wrap">{{ school.notes }}</p>
          </div>
        </div>
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
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 placeholder-gray-500"
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
const hasUsageRequirements = computed(() => {
  return school.value && (
    school.value.student_count || 
    school.value.club_count || 
    school.value.expected_start_date || 
    school.value.notes
  )
})

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

const getSchoolTypeText = (type: string) => {
  switch (type) {
    case 'elementary':
      return '國小'
    case 'junior_high':
      return '國中'
    case 'senior_high':
      return '高中'
    case 'vocational':
      return '高職'
    case 'university':
      return '大學'
    default:
      return type
  }
}

const getStudentCountText = (count: string) => {
  switch (count) {
    case '100':
      return '100 人以下'
    case '500':
      return '100-500 人'
    case '1000':
      return '500-1000 人'
    case '2000':
      return '1000-2000 人'
    case '2000+':
      return '2000 人以上'
    default:
      return count
  }
}

const getClubCountText = (count: string) => {
  switch (count) {
    case '10':
      return '10 個以下'
    case '30':
      return '10-30 個'
    case '50':
      return '30-50 個'
    case '100':
      return '50-100 個'
    case '100+':
      return '100 個以上'
    default:
      return count
  }
}

// 生命週期
onMounted(() => {
  refreshData()
})
</script>