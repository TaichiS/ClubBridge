<template>
  <div class="p-6">
    <!-- 頁面標題 -->
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">選社結果查詢</h1>
      <p class="mt-2 text-gray-600">查看學生分配結果，支援班級或社團方式查詢</p>
    </div>

    <!-- 查詢方式切換 -->
    <div class="mb-6">
      <div class="bg-gray-100 p-1 rounded-lg inline-flex">
        <button
          @click="queryMode = 'class'"
          :class="[
            'px-4 py-2 rounded-md text-sm font-medium transition-all',
            queryMode === 'class'
              ? 'bg-white text-blue-600 shadow-sm'
              : 'text-gray-500 hover:text-gray-700'
          ]"
        >
          依班級查詢
        </button>
        <button
          @click="queryMode = 'club'"
          :class="[
            'px-4 py-2 rounded-md text-sm font-medium transition-all',
            queryMode === 'club'
              ? 'bg-white text-blue-600 shadow-sm'
              : 'text-gray-500 hover:text-gray-700'
          ]"
        >
          依社團查詢
        </button>
      </div>
    </div>

    <!-- 班級查詢模式 -->
    <div v-if="queryMode === 'class'" class="space-y-6">
      <!-- 班級選擇器 -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">選擇班級</h2>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">年級</label>
            <select
              v-model="selectedGrade"
              @change="loadClassList"
              class="text-gray-600 w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            >
              <option value="">請選擇年級</option>
              <option v-for="grade in availableGrades" :key="grade" :value="grade">
                {{ getGradeName(grade) }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">班級</label>
            <select
              v-model="selectedClass"
              @change="loadClassResults"
              :disabled="!selectedGrade"
              class="text-gray-600 w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 disabled:bg-gray-100"
            >
              <option value="">請選擇班級</option>
              <option v-for="classInfo in availableClasses" :key="classInfo.class_number" :value="classInfo.class_number">
                {{ classInfo.class_name }}
              </option>
            </select>
          </div>
        </div>

        <div class="flex space-x-4">
          <button
            @click="loadClassResults"
            :disabled="!selectedGrade || !selectedClass || loading"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            {{ loading ? '查詢中...' : '查詢結果' }}
          </button>

          <button
            @click="exportClassResults"
            v-if="classResults.length > 0"
            class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
          >
            匯出 Excel
          </button>
        </div>
      </div>

      <!-- 班級結果顯示 -->
      <div v-if="classResults.length > 0" class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">
            {{ getGradeName(parseInt(selectedGrade)) }}{{ getClassName(parseInt(selectedClass)) }} 選社結果
          </h3>
          <p class="text-sm text-gray-500 mt-1">
            共 {{ classResults.length }} 位學生
          </p>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">座號</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">學號</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">姓名</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">分配社團</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">分配類型</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">分配時間</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="result in classResults" :key="result.student_id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ result.seat_number }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ result.student_number }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {{ result.name }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span v-if="result.club_name" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    {{ result.club_name }}
                  </span>
                  <span v-else class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                    未分配
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span v-if="result.assignment_type" :class="getAssignmentTypeClass(result.assignment_type)">
                    {{ getAssignmentTypeName(result.assignment_type) }}
                  </span>
                  <span v-else class="text-gray-400">-</span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ result.assigned_at ? formatDate(result.assigned_at) : '-' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- 社團查詢模式 -->
    <div v-if="queryMode === 'club'" class="space-y-6">
      <!-- 社團選擇器 -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">選擇社團</h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">社團</label>
            <select
              v-model="selectedClub"
              @change="loadClubResults"
              class="text-gray-600 w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            >
              <option value="">請選擇社團</option>
              <option v-for="club in availableClubs" :key="club.id" :value="club.id">
                {{ club.name }} ({{ club.category }})
              </option>
            </select>
          </div>
        </div>

        <div class="flex space-x-4">
          <button
            @click="loadClubResults"
            :disabled="!selectedClub || loading"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            {{ loading ? '查詢中...' : '查詢結果' }}
          </button>

          <button
            @click="exportClubResults"
            v-if="clubResults.length > 0"
            class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
          >
            匯出 Excel
          </button>

          <button
            @click="printAttendanceSheet"
            v-if="clubResults.length > 0"
            class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700"
          >
            列印點名單
          </button>
        </div>
      </div>

      <!-- 社團結果顯示 -->
      <div v-if="clubResults.length > 0" class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">
            {{ selectedClubInfo?.name }} 成員名單
          </h3>
          <p class="text-sm text-gray-500 mt-1">
            共 {{ clubResults.length }} 位學生 / 最大人數: {{ selectedClubInfo?.max_members || '-' }}
          </p>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">年級班級</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">座號</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">學號</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">姓名</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">分配類型</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">分配時間</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="result in clubResults" :key="result.student_id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ getGradeName(result.grade) }}{{ result.class_name || getClassName(result.class_number) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ result.seat_number }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ result.student_number }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {{ result.name }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="getAssignmentTypeClass(result.assignment_type)">
                    {{ getAssignmentTypeName(result.assignment_type) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(result.assigned_at) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- 無資料狀態 -->
    <div v-if="showNoResults" class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">無查詢結果</h3>
      <p class="mt-1 text-sm text-gray-500">請選擇班級或社團進行查詢</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { apiClient } from '@/api/client'

const route = useRoute()
const schoolId = route.params.schoolId as string

// 響應式資料
const queryMode = ref<'class' | 'club'>('class')
const loading = ref(false)

// 班級查詢相關
const selectedGrade = ref('')
const selectedClass = ref('')
const availableGrades = ref<number[]>([])
const availableClasses = ref<any[]>([])
const classResults = ref<any[]>([])

// 社團查詢相關
const selectedClub = ref('')
const availableClubs = ref<any[]>([])
const clubResults = ref<any[]>([])
const selectedClubInfo = computed(() => {
  return availableClubs.value.find(club => club.id === selectedClub.value)
})

// 計算屬性
const showNoResults = computed(() => {
  if (queryMode.value === 'class') {
    return selectedGrade.value && selectedClass.value && classResults.value.length === 0 && !loading.value
  } else {
    return selectedClub.value && clubResults.value.length === 0 && !loading.value
  }
})

// 輔助函數
const getGradeName = (grade: number): string => {
  const gradeNames: { [key: number]: string } = {
    1: '國一', 2: '國二', 3: '國三',
    4: '高一', 5: '高二', 6: '高三'
  }
  return gradeNames[grade] || `${grade}年級`
}

const getClassName = (classNumber: number): string => {
  const classNames = ['', '忠', '孝', '仁', '愛', '信', '義', '和', '平', '勇', '毅']
  return classNames[classNumber] || `${classNumber}班`
}

const getAssignmentTypeName = (type: string): string => {
  const typeNames: { [key: string]: string } = {
    'special': '指定分配',
    'normal': '一般分配',
    'manual': '手動分配'
  }
  return typeNames[type] || type
}

const getAssignmentTypeClass = (type: string): string => {
  const typeClasses: { [key: string]: string } = {
    'special': 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800',
    'normal': 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800',
    'manual': 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800'
  }
  return typeClasses[type] || 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800'
}

const formatDate = (dateString: string): string => {
  const date = new Date(dateString)
  return date.toLocaleString('zh-TW', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// API 呼叫函數
const loadInitialData = async () => {
  loading.value = true
  try {
    // 載入年級資料
    availableGrades.value = await apiClient.get(`/api/schools/${schoolId}/students/grades`)

    // 載入社團資料
    availableClubs.value = await apiClient.get(`/api/schools/${schoolId}/clubs`)
  } catch (error) {
    console.error('載入初始資料失敗:', error)
    alert('載入初始資料失敗')
  } finally {
    loading.value = false
  }
}

const loadClassList = async () => {
  if (!selectedGrade.value) return

  selectedClass.value = ''
  classResults.value = []

  try {
    availableClasses.value = await apiClient.get(`/api/schools/${schoolId}/students/classes?grade=${selectedGrade.value}`)
  } catch (error) {
    console.error('載入班級列表失敗:', error)
    alert('載入班級列表失敗')
  }
}

const loadClassResults = async () => {
  if (!selectedGrade.value || !selectedClass.value) return

  loading.value = true
  try {
    classResults.value = await apiClient.get(`/api/schools/${schoolId}/admin/results/class?grade=${selectedGrade.value}&class=${selectedClass.value}`)
  } catch (error) {
    console.error('載入班級結果失敗:', error)
    alert('載入班級結果失敗')
  } finally {
    loading.value = false
  }
}

const loadClubResults = async () => {
  if (!selectedClub.value) return

  loading.value = true
  try {
    clubResults.value = await apiClient.get(`/api/schools/${schoolId}/admin/results/club/${selectedClub.value}`)
  } catch (error) {
    console.error('載入社團結果失敗:', error)
    alert('載入社團結果失敗')
  } finally {
    loading.value = false
  }
}

// 匯出功能
const exportClassResults = async () => {
  try {
    const response = await apiClient.getRawClient().get(`/api/schools/${schoolId}/admin/results/class/export?grade=${selectedGrade.value}&class=${selectedClass.value}`, {
      responseType: 'blob'
    })
    const blob = new Blob([response.data])
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${getGradeName(parseInt(selectedGrade.value))}${getClassName(parseInt(selectedClass.value))}_選社結果.xlsx`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    alert('匯出成功')
  } catch (error) {
    console.error('匯出失敗:', error)
    alert('匯出失敗')
  }
}

const exportClubResults = async () => {
  try {
    const response = await apiClient.getRawClient().get(`/api/schools/${schoolId}/admin/results/club/${selectedClub.value}/export`, {
      responseType: 'blob'
    })
    const blob = new Blob([response.data])
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${selectedClubInfo.value?.name}_成員名單.xlsx`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    alert('匯出成功')
  } catch (error) {
    console.error('匯出失敗:', error)
    alert('匯出失敗')
  }
}

const printAttendanceSheet = () => {
  const printWindow = window.open('', '_blank')
  if (!printWindow) return

  const printContent = `
    <html>
      <head>
        <title>${selectedClubInfo.value?.name} 點名單</title>
        <style>
          body { font-family: 'Microsoft JhengHei', Arial, sans-serif; }
          table { border-collapse: collapse; width: 100%; }
          th, td { border: 1px solid #000; padding: 8px; text-align: left; }
          th { background-color: #f0f0f0; }
          .header { text-align: center; margin-bottom: 20px; }
          .attendance-col { width: 80px; }
          @media print { body { margin: 0; } }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>${selectedClubInfo.value?.name} 點名單</h2>
          <p>指導老師：${selectedClubInfo.value?.teacher_name || ''} | 上課地點：${selectedClubInfo.value?.location || ''}</p>
          <p>日期：_____ 年 _____ 月 _____ 日</p>
        </div>
        <table>
          <thead>
            <tr>
              <th>序號</th>
              <th>年級班級</th>
              <th>座號</th>
              <th>學號</th>
              <th>姓名</th>
              <th class="attendance-col">出席</th>
              <th class="attendance-col">備註</th>
            </tr>
          </thead>
          <tbody>
            ${clubResults.value.map((student, index) => `
              <tr>
                <td>${index + 1}</td>
                <td>${getGradeName(student.grade)}${student.class_name || getClassName(student.class_number)}</td>
                <td>${student.seat_number}</td>
                <td>${student.student_number}</td>
                <td>${student.name}</td>
                <td></td>
                <td></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </body>
    </html>
  `

  printWindow.document.write(printContent)
  printWindow.document.close()
  printWindow.print()
}

// 生命週期
onMounted(() => {
  loadInitialData()
})
</script>