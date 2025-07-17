<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-6 text-gray-800">指定入社</h1>
    
    <!-- 搜尋社團區域 -->
    <div class="bg-white rounded-lg shadow-sm border p-6 mb-6">
      <h2 class="text-lg font-semibold mb-4 text-gray-500">搜尋社團</h2>
      <div class="flex gap-4 mb-4">
        <div class="flex-1">
          <input
            v-model="clubSearchQuery"
            type="text"
            placeholder="輸入社團名稱或編號"
            class="w-full px-4 py-2 text-red-600 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            @input="searchClubs"
          />
        </div>
        <button
          @click="searchClubs"
          class="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
        >
          搜尋
        </button>
      </div>
      
      <!-- 搜尋結果 -->
      <div v-if="clubSearchResults.length > 0" class="space-y-2">
        <div
          v-for="club in clubSearchResults"
          :key="club.id"
          class="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50 cursor-pointer"
          @click="selectClub(club)"
        >
          <div>
            <h3 class="font-medium text-stone-800">{{ club.name }}</h3>
            <p class="text-sm text-gray-600">編號: {{ club.club_number }} | 指導老師: {{ club.teacher_name }}</p>
          </div>
          <div class="text-sm text-gray-500">
            {{ club.current_members }}/{{ club.max_members }} 人
          </div>
        </div>
      </div>
    </div>

    <!-- 選中社團的詳細資訊 -->
    <div v-if="selectedClub" class="bg-white rounded-lg shadow-sm border p-6 mb-6">
      <h2 class="text-lg font-semibold mb-4 text-gray-500">
        為「{{ selectedClub.name }}」指定學生
      </h2>
      
      <!-- 搜尋學生 -->
      <div class="flex gap-4 mb-4">
        <div class="flex-1">
          <input
            v-model="studentSearchQuery"
            type="text"
            placeholder="輸入學生學號或姓名"
            class="w-full px-4 py-2 text-red-600 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            @input="searchStudents"
          />
        </div>
        <button
          @click="searchStudents"
          class="px-6 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
        >
          搜尋學生
        </button>
      </div>
      
      <!-- 學生搜尋結果 -->
      <div v-if="studentSearchResults.length > 0" class="space-y-2">
        <div
          v-for="student in studentSearchResults"
          :key="student.id"
          class="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50"
        >
          <div>
            <h3 class="font-medium text-stone-800">{{ student.name }}</h3>
            <p class="text-sm text-gray-600">
              學號: {{ student.student_number }} | 
              {{ student.grade }}{{ student.class_name }}{{ student.seat_number }}號
            </p>
          </div>
          <button
            @click="assignStudent(student)"
            :disabled="loading"
            class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
          >
            {{ loading ? '處理中...' : '指定入社' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 特殊身份學生列表 -->
    <div class="bg-white rounded-lg shadow-sm border p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-500">特殊身份學生列表</h2>
        <button
          @click="loadSpecialStudents"
          class="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
        >
          重新載入
        </button>
      </div>
      
      <div v-if="loading" class="text-center py-8">
        <div class="text-gray-600">載入中...</div>
      </div>
      
      <div v-else-if="specialStudents.length === 0" class="text-center py-8">
        <div class="text-gray-600">目前沒有特殊身份學生</div>
      </div>
      
      <div v-else class="space-y-2">
        <div
          v-for="student in specialStudents"
          :key="student.id"
          class="flex items-center justify-between p-4 border rounded-lg"
        >
          <div class="flex-1">
            <h3 class="font-medium text-gray-800">{{ student.name }}</h3>
            <p class="text-sm text-gray-600">
              學號: {{ student.student_number }} | 
              {{ student.grade }}{{ student.class_name }}{{ student.seat_number }}號
            </p>
            <p v-if="student.assigned_club" class="text-sm text-green-600">
              已指定：{{ student.assigned_club.name }}
            </p>
          </div>
          <button
            @click="revokeSpecialStatus(student)"
            :disabled="loading"
            class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors disabled:opacity-50"
          >
            {{ loading ? '處理中...' : '撤銷' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 成功/錯誤訊息 -->
    <div v-if="message" class="fixed top-4 right-4 z-50">
      <div
        :class="[
          'p-4 rounded-lg shadow-lg max-w-md',
          messageType === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
        ]"
      >
        {{ message }}
      </div>
    </div>

    <!-- 確認覆蓋對話框 -->
    <div v-if="showConfirmDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold mb-4">確認覆蓋學生志願</h3>
        
        <div class="mb-4">
          <p class="text-gray-700 mb-2">{{ confirmDialogData.message }}</p>
          
          <div v-if="confirmDialogData.existingClubs.length > 0" class="bg-yellow-50 border border-yellow-200 rounded p-3">
            <p class="text-sm font-medium text-yellow-800 mb-2">現有志願：</p>
            <ul class="text-sm text-yellow-700">
              <li v-for="club in confirmDialogData.existingClubs" :key="club" class="mb-1">
                • {{ club }}
              </li>
            </ul>
          </div>
          
          <div v-if="selectedClub" class="bg-blue-50 border border-blue-200 rounded p-3 mt-3">
            <p class="text-sm font-medium text-blue-800 mb-1">將指定到：</p>
            <p class="text-sm text-blue-700">{{ selectedClub.name }}</p>
          </div>
        </div>
        
        <div class="flex gap-3 justify-end">
          <button
            @click="handleCancelOverride"
            class="px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
          >
            取消
          </button>
          <button
            @click="handleConfirmOverride"
            class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
          >
            確認覆蓋
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { assignmentApi, type SpecialStudent } from '@/api/assignment'
import { clubApi } from '@/api/club'
import type { Club } from '@/types/club'
import type { Student } from '@/types/student'

// 狀態管理
const authStore = useAuthStore()
const loading = ref(false)
const message = ref('')
const messageType = ref<'success' | 'error'>('success')

// 確認對話框狀態
const showConfirmDialog = ref(false)
const confirmDialogData = ref<{
  student: Student | null
  existingClubs: string[]
  message: string
}>({
  student: null,
  existingClubs: [],
  message: ''
})

// 搜尋相關
const clubSearchQuery = ref('')
const studentSearchQuery = ref('')
const clubSearchResults = ref<Club[]>([])
const studentSearchResults = ref<Student[]>([])
const selectedClub = ref<Club | null>(null)

// 特殊身份學生列表
const specialStudents = ref<SpecialStudent[]>([])

// 搜尋社團
const searchClubs = async () => {
  if (!clubSearchQuery.value.trim()) {
    clubSearchResults.value = []
    return
  }
  
  try {
    loading.value = true
    const schools = authStore.currentSchool
    if (!schools) return
    
    clubSearchResults.value = await clubApi.searchClubs(schools, clubSearchQuery.value)
  } catch (error: any) {
    showMessage(error.message || '搜尋社團失敗', 'error')
  } finally {
    loading.value = false
  }
}

// 選擇社團
const selectClub = (club: Club) => {
  selectedClub.value = club
  studentSearchQuery.value = ''
  studentSearchResults.value = []
}

// 搜尋學生
const searchStudents = async () => {
  if (!studentSearchQuery.value.trim() || !selectedClub.value) {
    studentSearchResults.value = []
    return
  }
  
  try {
    loading.value = true
    const schools = authStore.currentSchool
    if (!schools) return
    
    studentSearchResults.value = await assignmentApi.searchStudents(schools, studentSearchQuery.value)
  } catch (error: any) {
    showMessage(error.message || '搜尋學生失敗', 'error')
  } finally {
    loading.value = false
  }
}

// 指定學生入社
const assignStudent = async (student: Student, forceOverride: boolean = false) => {
  if (!selectedClub.value) return
  
  try {
    loading.value = true
    const schools = authStore.currentSchool
    if (!schools) return
    
    const response = await assignmentApi.assignStudentToClub(schools, student.id, selectedClub.value.id, forceOverride)
    showMessage(response.message, 'success')
    
    // 重新載入特殊身份學生列表
    await loadSpecialStudents()
    
    // 清空搜尋結果
    studentSearchResults.value = []
    studentSearchQuery.value = ''
    
  } catch (error: any) {
    if (error.status === 409 && error.requires_confirmation) {
      // 需要確認是否覆蓋，顯示自定義確認對話框
      confirmDialogData.value = {
        student: student,
        existingClubs: error.existing_clubs || [],
        message: error.message || '此學生已經自行選社完畢，是否要覆蓋他的志願？'
      }
      showConfirmDialog.value = true
    } else {
      showMessage(error.message || '指定學生入社失敗', 'error')
    }
  } finally {
    loading.value = false
  }
}

// 撤銷特殊身份
const revokeSpecialStatus = async (student: SpecialStudent) => {
  if (!confirm(`確定要撤銷 ${student.name} 的特殊身份嗎？`)) return
  
  try {
    loading.value = true
    const schools = authStore.currentSchool
    if (!schools) return
    
    const response = await assignmentApi.revokeSpecialStatus(schools, student.id)
    showMessage(response.message, 'success')
    
    // 重新載入特殊身份學生列表
    await loadSpecialStudents()
    
  } catch (error: any) {
    showMessage(error.message || '撤銷特殊身份失敗', 'error')
  } finally {
    loading.value = false
  }
}

// 載入特殊身份學生
const loadSpecialStudents = async () => {
  try {
    loading.value = true
    const schools = authStore.currentSchool
    if (!schools) return
    
    specialStudents.value = await assignmentApi.getSpecialStudents(schools)
  } catch (error: any) {
    showMessage(error.message || '載入特殊身份學生失敗', 'error')
  } finally {
    loading.value = false
  }
}

// 處理確認對話框
const handleConfirmOverride = async () => {
  if (!confirmDialogData.value.student || !selectedClub.value) return
  
  showConfirmDialog.value = false
  
  // 重新呼叫 API，強制覆蓋
  await assignStudent(confirmDialogData.value.student, true)
  
  // 清空確認對話框資料
  confirmDialogData.value = {
    student: null,
    existingClubs: [],
    message: ''
  }
}

const handleCancelOverride = () => {
  showConfirmDialog.value = false
  confirmDialogData.value = {
    student: null,
    existingClubs: [],
    message: ''
  }
}

// 顯示訊息
const showMessage = (text: string, type: 'success' | 'error') => {
  message.value = text
  messageType.value = type
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

// 初始化
onMounted(() => {
  loadSpecialStudents()
})
</script>
