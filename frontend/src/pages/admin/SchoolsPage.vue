<template>
  <div class="p-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-900">學校管理</h1>
      <button
        @click="refreshData"
        :disabled="isLoading"
        class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {{ isLoading ? '載入中...' : '重新整理' }}
      </button>
    </div>

    <!-- 統計卡片 -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-blue-100">
            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">總學校數</p>
            <p class="text-2xl font-bold text-gray-900">{{ allSchools.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-yellow-100">
            <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">待審核</p>
            <p class="text-2xl font-bold text-gray-900">{{ pendingSchools.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-green-100">
            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">已核准</p>
            <p class="text-2xl font-bold text-gray-900">{{ approvedSchools.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-red-100">
            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">已拒絕</p>
            <p class="text-2xl font-bold text-gray-900">{{ rejectedSchools.length }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 待審核學校 -->
    <div v-if="pendingSchools.length > 0" class="mb-8">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">待審核學校申請</h2>
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">學校名稱</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">申請人</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">申請時間</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">狀態</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="school in pendingSchools" :key="school.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="text-sm font-medium text-gray-900">{{ school.name }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900">{{ school.applicant_name }}</div>
                <div class="text-sm text-gray-500">{{ school.applicant_email }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ formatDate(school.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                  待審核
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  @click="viewSchoolDetail(school.id)"
                  class="text-blue-600 hover:text-blue-900 mr-3"
                >
                  查看詳情
                </button>
                <button
                  @click="approveSchool(school.id)"
                  :disabled="isLoading"
                  class="text-green-600 hover:text-green-900 mr-3 disabled:opacity-50"
                >
                  核准
                </button>
                <button
                  @click="showRejectModal(school)"
                  :disabled="isLoading"
                  class="text-red-600 hover:text-red-900 disabled:opacity-50"
                >
                  拒絕
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 所有學校列表 -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-xl font-semibold text-gray-900">所有學校</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">學校名稱</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">申請人</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">建立時間</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">狀態</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="school in allSchools" :key="school.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="text-sm font-medium text-gray-900">{{ school.name }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900">{{ school.applicant_name }}</div>
                <div class="text-sm text-gray-500">{{ school.applicant_email }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ formatDate(school.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="getStatusClass(school.status)">
                  {{ getStatusText(school.status) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  @click="viewSchoolDetail(school.id)"
                  class="text-blue-600 hover:text-blue-900"
                >
                  查看詳情
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 拒絕理由對話框 -->
    <div v-if="showRejectDialog" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3 text-center">
          <h3 class="text-lg leading-6 font-medium text-gray-900">拒絕學校申請</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500 mb-4">
              您確定要拒絕「{{ selectedSchool?.name }}」的申請嗎？
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
import { useRouter } from 'vue-router'
import { useSchoolStore } from '@/stores/school'
import type { School } from '@/types/school'

const router = useRouter()
const schoolStore = useSchoolStore()

// 響應式狀態
const allSchools = ref<School[]>([])
const showRejectDialog = ref(false)
const selectedSchool = ref<School | null>(null)
const rejectReason = ref('')

// 計算屬性
const isLoading = computed(() => schoolStore.isLoading)
const pendingSchools = computed(() => schoolStore.applications.filter(school => school.status === 'pending'))
const approvedSchools = computed(() => allSchools.value.filter(school => school.status === 'approved'))
const rejectedSchools = computed(() => allSchools.value.filter(school => school.status === 'rejected'))

// 方法
const refreshData = async () => {
  try {
    await Promise.all([
      schoolStore.fetchPendingApplications(),
      loadAllSchools()
    ])
  } catch (error) {
    console.error('重新整理失敗:', error)
  }
}

const loadAllSchools = async () => {
  try {
    allSchools.value = await schoolStore.fetchAllSchools()
  } catch (error) {
    console.error('載入所有學校失敗:', error)
  }
}

const approveSchool = async (schoolId: number) => {
  try {
    await schoolStore.approveSchool(schoolId)
    await refreshData()
    alert('學校申請已核准')
  } catch (error) {
    console.error('核准學校失敗:', error)
    alert('核准失敗，請稍後再試')
  }
}

const showRejectModal = (school: School) => {
  selectedSchool.value = school
  rejectReason.value = ''
  showRejectDialog.value = true
}

const hideRejectModal = () => {
  showRejectDialog.value = false
  selectedSchool.value = null
  rejectReason.value = ''
}

const confirmReject = async () => {
  if (!selectedSchool.value) return
  
  try {
    await schoolStore.rejectSchool(selectedSchool.value.id, rejectReason.value)
    await refreshData()
    hideRejectModal()
    alert('學校申請已拒絕')
  } catch (error) {
    console.error('拒絕學校失敗:', error)
    alert('拒絕失敗，請稍後再試')
  }
}

const viewSchoolDetail = (schoolId: number) => {
  router.push(`/admin/schools/${schoolId}`)
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
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800'
    case 'approved':
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800'
    case 'rejected':
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800'
    default:
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800'
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