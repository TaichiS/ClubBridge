<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
    <!-- 載入狀態 -->
    <div v-if="isLoading" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-8 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p class="text-gray-600">載入中...</p>
      </div>
    </div>

    <!-- 錯誤狀態 -->
    <div v-else-if="error" class="min-h-screen flex items-center justify-center">
      <div class="bg-white rounded-lg p-8 text-center shadow-lg">
        <div class="text-red-500 text-6xl mb-4">❌</div>
        <h2 class="text-2xl font-bold text-gray-900 mb-4">載入失敗</h2>
        <p class="text-gray-600 mb-6">{{ error }}</p>
        <button 
          @click="loadData()" 
          class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          重新載入
        </button>
      </div>
    </div>

    <!-- 頂部導航 -->
    <nav v-else class="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-4">
            <button @click="goBack" class="text-gray-600 hover:text-gray-900">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
              </svg>
            </button>
            <h1 class="text-xl font-bold text-gray-900">社團選擇</h1>
          </div>
          
          <div class="flex items-center space-x-4">
            <div class="text-sm text-gray-600">
              剩餘時間: <span class="font-semibold text-red-600">{{ timeRemaining }}</span>
            </div>
            <button
              @click="submitSelection"
              :disabled="!canSubmit"
              class="px-6 py-2 bg-gradient-to-r from-green-500 to-blue-600 text-white rounded-lg hover:from-green-600 hover:to-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-md hover:shadow-lg transform hover:scale-105"
            >
              {{ isSubmitting ? '提交中...' : '提交志願' }}
            </button>
          </div>
        </div>
      </div>
    </nav>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- 學生資訊卡片 -->
      <div class="bg-white/80 backdrop-blur-sm rounded-xl shadow-lg p-6 mb-8 border border-gray-200">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <div class="w-12 h-12 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
              <span class="text-white font-bold">{{ studentInfo.name.charAt(0) }}</span>
            </div>
            <div>
              <h2 class="text-lg font-semibold text-gray-900">{{ studentInfo.name }}</h2>
              <p class="text-sm text-gray-600">{{ studentInfo.grade }}年{{ studentInfo.class }}班</p>
            </div>
          </div>
          <div class="text-right">
            <p class="text-sm text-gray-600">學號</p>
            <p class="font-semibold text-gray-900">{{ studentInfo.studentId }}</p>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- 左側：社團列表 -->
        <div class="lg:col-span-2">
          <div class="bg-white/80 backdrop-blur-sm rounded-xl shadow-lg border border-gray-200">
            <!-- 搜尋和篩選 -->
            <div class="p-6 border-b border-gray-200">
              <div class="flex flex-col sm:flex-row gap-4">
                <div class="relative flex-1">
                  <input
                    v-model="searchTerm"
                    type="text"
                    placeholder="搜尋社團名稱..."
                    class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                  </div>
                </div>
                
                <select 
                  v-model="selectedCategory"
                  class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="">所有分類</option>
                  <option v-for="category in categories" :key="category" :value="category">
                    {{ category }}
                  </option>
                </select>
                
                <button
                  @click="showAvailableOnly = !showAvailableOnly"
                  :class="[
                    'px-4 py-2 rounded-lg transition-all duration-200',
                    showAvailableOnly 
                      ? 'bg-blue-500 text-white' 
                      : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                  ]"
                >
                  {{ showAvailableOnly ? '顯示全部' : '僅顯示有名額' }}
                </button>
              </div>
            </div>

            <!-- 社團列表 -->
            <div class="p-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div
                  v-for="club in filteredClubs"
                  :key="club.id"
                  class="group relative bg-white rounded-lg shadow-md hover:shadow-lg transition-all duration-300 border border-gray-200 hover:border-blue-300 cursor-pointer transform hover:-translate-y-1"
                  :class="{ 
                    'opacity-50': club.availableSpots === 0,
                    'opacity-60 bg-gray-50': isClubSelected(club.id)
                  }"
                  @click="addToSelection(club)"
                  draggable="true"
                  @dragstart="onDragStart($event, club)"
                >
                  <div class="p-4">
                    <div class="flex items-start justify-between mb-3">
                      <div class="flex-1">
                        <h3 class="font-semibold text-gray-900 group-hover:text-blue-600 transition-colors duration-200">
                          {{ club.name }}
                        </h3>
                        <p class="text-sm text-gray-600 mt-1">{{ club.teacher }}</p>
                      </div>
                      <div :class="[
                        'px-2 py-1 rounded text-xs font-medium',
                        club.availableSpots > 0 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      ]">
                        {{ club.availableSpots > 0 ? `${club.availableSpots}名額` : '已滿' }}
                      </div>
                    </div>
                    
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-2">
                        <span :class="[
                          'px-2 py-1 rounded text-xs font-medium',
                          club.categoryColor
                        ]">
                          {{ club.category }}
                        </span>
                        <span v-if="club.isPopular" class="text-xs text-yellow-600">🔥 熱門</span>
                      </div>
                      <div class="text-sm text-gray-500">
                        {{ club.currentCount }}/{{ club.maxCapacity }}
                      </div>
                    </div>
                    
                    <div class="mt-2 text-sm text-gray-600">
                      📍 {{ club.location }}
                    </div>
                  </div>
                  
                  <!-- 已選擇指示器 -->
                  <div v-if="isClubSelected(club.id)" class="absolute top-2 right-2 bg-green-500 text-white rounded-full w-6 h-6 flex items-center justify-center">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                  </div>
                  
                  <!-- 拖拽指示器 -->
                  <div v-else class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                    <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"></path>
                    </svg>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 右側：已選志願 -->
        <div class="lg:col-span-1">
          <div class="bg-white/80 backdrop-blur-sm rounded-xl shadow-lg border border-gray-200 sticky top-24">
            <div class="p-6 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900 mb-2">我的志願序</h3>
              <p class="text-sm text-gray-600">拖拽調整順序</p>
              <div class="mt-2 flex items-center justify-between">
                <div class="text-sm text-gray-500">
                  最少需選 {{ minRequiredChoices }} 個志願
                </div>
                <div :class="[
                  'text-sm px-2 py-1 rounded',
                  selectedClubs.length >= minRequiredChoices 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-yellow-100 text-yellow-800'
                ]">
                  {{ selectedClubs.length >= minRequiredChoices ? '✅ 符合要求' : '⚠️ 尚未達標' }}
                </div>
              </div>
            </div>

            <!-- 志願列表 -->
            <div class="p-6">
              <div
                v-if="selectedClubs.length === 0"
                class="text-center py-12 text-gray-500"
              >
                <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                  <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                </div>
                <p class="text-sm">尚未選擇任何社團</p>
                <p class="text-xs mt-1">點擊左側社團或拖拽至此</p>
              </div>

              <div
                v-else
                class="space-y-3"
                @dragover.prevent
                @drop="onDrop"
              >
                <div
                  v-for="(club, index) in selectedClubs"
                  :key="club.id"
                  class="relative bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-lg p-4 transition-all duration-300 hover:shadow-md"
                  :class="[
                    dragState.isDragging && dragState.draggedIndex === index ? 'opacity-50 scale-95' : '',
                    dragState.draggedOverIndex === index ? 'ring-2 ring-blue-400' : ''
                  ]"
                  draggable="true"
                  @dragstart="onDragStartInSelection($event, club, index)"
                  @dragend="onDragEnd"
                  @dragover.prevent="onDragOver(index)"
                  @dragleave="onDragLeave"
                >
                  <!-- 志願序號 -->
                  <div class="absolute -left-2 -top-2 w-6 h-6 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-full flex items-center justify-center text-xs font-bold">
                    {{ index + 1 }}
                  </div>

                  <!-- 拖拽手柄 -->
                  <div class="absolute right-2 top-2 cursor-move">
                    <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8h16M4 16h16"></path>
                    </svg>
                  </div>

                  <div class="pr-8">
                    <h4 class="font-semibold text-gray-900 mb-1">{{ club.clubName }}</h4>
                    <p class="text-sm text-gray-600 mb-2">{{ club.clubCategory }}</p>
                    <div class="flex items-center justify-between">
                      <div :class="[
                        'text-xs px-2 py-1 rounded',
                        club.isEligible ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      ]">
                        {{ club.isEligible ? '符合條件' : '不符合條件' }}
                      </div>
                      <button
                        @click="removeFromSelection(index)"
                        class="text-red-500 hover:text-red-700 transition-colors duration-200"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 提交按鈕 -->
              <div class="mt-6 pt-6 border-t border-gray-200">
                <button
                  @click="submitSelection"
                  :disabled="!canSubmit"
                  class="w-full py-3 bg-gradient-to-r from-green-500 to-blue-600 text-white rounded-lg hover:from-green-600 hover:to-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-md hover:shadow-lg transform hover:scale-105"
                >
                  {{ isSubmitting ? '提交中...' : selectedClubs.length > 0 ? `提交 ${selectedClubs.length} 個志願` : `需選擇至少 ${minRequiredChoices} 個志願` }}
                </button>
                <p class="text-xs text-gray-500 mt-2 text-center">
                  提交後仍可修改，直到報名截止
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 確認對話框 -->
    <div v-if="showConfirmModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl p-6 max-w-md w-full mx-4 shadow-2xl">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">確認提交志願</h3>
        <p class="text-gray-600 mb-6">
          您即將提交 {{ selectedClubs.length }} 個志願。提交後您仍可在報名截止前修改志願序。
        </p>
        <div class="flex space-x-4">
          <button
            @click="showConfirmModal = false"
            class="flex-1 py-2 px-4 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors duration-200"
          >
            取消
          </button>
          <button
            @click="confirmSubmit"
            class="flex-1 py-2 px-4 bg-gradient-to-r from-green-500 to-blue-600 text-white rounded-lg hover:from-green-600 hover:to-blue-700 transition-all duration-200"
          >
            確認提交
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { clubApi } from '@/api/club'
import { schoolApi } from '@/api/school'
import { studentApi } from '@/api/student'
import { useAuthStore } from '@/stores/auth'
import type { ClubCard } from '@/student/types/club'
import type { StudentInfo, ClubPreference, DragState } from '@/student/types/student'
import type { Club } from '@/types/club'
import type { School } from '@/types/school'

const route = useRoute()
const authStore = useAuthStore()

// 響應式資料
const isLoading = ref(true)
const error = ref<string | null>(null)
const realClubs = ref<Club[]>([])
const schoolInfo = ref<School | null>(null)

// 學生資訊（從認證系統取得真實資料）
const studentInfo = computed<StudentInfo>(() => {
  if (authStore.isStudent && authStore.user) {
    return {
      id: authStore.user.id.toString(),
      studentId: authStore.user.student_id || 'N/A',
      name: authStore.user.name,
      grade: authStore.user.grade || 1,
      class: authStore.user.class_name || 'N/A',
      classNumber: 1, // 班級編號，暫時預設為1
      gender: 'male', // 暫時預設，可以後續從資料庫取得
      idNumber: 'N/A', // 基於隱私考量，不顯示完整身分證字號
      schoolId: authStore.currentSchool?.toString() || 'N/A',
      isSpecialStudent: false
    }
  }
  
  // 如果未登入，返回預設資料
  return {
    id: 'guest',
    studentId: 'N/A',
    name: '未登入',
    grade: 1,
    class: 'N/A',
    classNumber: 1,
    gender: 'male',
    idNumber: 'N/A',
    schoolId: 'N/A',
    isSpecialStudent: false
  }
})

// 搜尋和篩選
const searchTerm = ref('')
const selectedCategory = ref('')
const showAvailableOnly = ref(false)

// 計算屬性
const schoolId = computed(() => {
  return Number(route.params.schoolId)
})

const minRequiredChoices = computed(() => {
  return schoolInfo.value?.min_required_choices || 3
})

// 將真實社團資料轉換為卡片格式
const clubs = computed<ClubCard[]>(() => {
  return realClubs.value.map(club => ({
    id: club.id.toString(),
    name: club.name,
    category: club.category,
    categoryColor: getCategoryColor(club.category),
    teacher: club.teacher_name,
    currentCount: club.current_members || 0,
    maxCapacity: club.max_members,
    availableSpots: club.max_members - (club.current_members || 0),
    location: club.location,
    image: `/images/club-${club.id}.jpg`,
    isPopular: (club.current_members || 0) > club.max_members * 0.8,
    rating: 4.0 + Math.random() * 0.8,
    tags: [club.category, '社團']
  }))
})

// 根據類別返回顏色
const getCategoryColor = (category: string): string => {
  const colors: Record<string, string> = {
    '體育類': 'bg-green-100 text-green-800',
    '藝文類': 'bg-purple-100 text-purple-800',
    '技能類': 'bg-blue-100 text-blue-800',
    '學術類': 'bg-yellow-100 text-yellow-800',
    '服務類': 'bg-pink-100 text-pink-800',
    '其他': 'bg-gray-100 text-gray-800'
  }
  return colors[category] || 'bg-gray-100 text-gray-800'
}

// 已選社團
const selectedClubs = ref<ClubPreference[]>([])

// 拖拽狀態
const dragState = ref<DragState>({
  isDragging: false,
  dropZoneActive: false
})

// 提交狀態
const isSubmitting = ref(false)
const showConfirmModal = ref(false)

// 時間相關
const timeRemaining = ref('7天3小時')

// 計算屬性
const categories = computed(() => {
  const categorySet = new Set(clubs.value.map(club => club.category))
  return Array.from(categorySet)
})

const filteredClubs = computed(() => {
  return clubs.value.filter(club => {
    const matchesSearch = club.name.toLowerCase().includes(searchTerm.value.toLowerCase())
    const matchesCategory = !selectedCategory.value || club.category === selectedCategory.value
    const matchesAvailability = !showAvailableOnly.value || club.availableSpots > 0
    
    return matchesSearch && matchesCategory && matchesAvailability
  })
})

const canSubmit = computed(() => {
  return selectedClubs.value.length >= minRequiredChoices.value && !isSubmitting.value
})

// 拖拽方法
const onDragStart = (event: DragEvent, club: ClubCard) => {
  dragState.value.isDragging = true
  event.dataTransfer?.setData('application/json', JSON.stringify({
    type: 'club',
    club: club
  }))
}

const onDragStartInSelection = (event: DragEvent, club: ClubPreference, index: number) => {
  dragState.value.isDragging = true
  dragState.value.draggedIndex = index
  dragState.value.draggedItem = club
  event.dataTransfer?.setData('application/json', JSON.stringify({
    type: 'preference',
    club: club,
    index: index
  }))
}

const onDragEnd = () => {
  dragState.value.isDragging = false
  dragState.value.draggedIndex = undefined
  dragState.value.draggedItem = undefined
  dragState.value.draggedOverIndex = undefined
}

const onDragOver = (index: number) => {
  if (dragState.value.isDragging) {
    dragState.value.draggedOverIndex = index
  }
}

const onDragLeave = () => {
  dragState.value.draggedOverIndex = undefined
}

const onDrop = (event: DragEvent) => {
  event.preventDefault()
  const data = JSON.parse(event.dataTransfer?.getData('application/json') || '{}')
  
  if (data.type === 'club') {
    addToSelection(data.club)
  } else if (data.type === 'preference') {
    // 處理志願序重新排序
    const draggedIndex = data.index
    const targetIndex = dragState.value.draggedOverIndex
    
    if (draggedIndex !== undefined && targetIndex !== undefined && draggedIndex !== targetIndex) {
      const newSelection = [...selectedClubs.value]
      const draggedItem = newSelection.splice(draggedIndex, 1)[0]
      newSelection.splice(targetIndex, 0, draggedItem)
      
      // 更新 priority
      newSelection.forEach((club, index) => {
        club.priority = index + 1
      })
      
      selectedClubs.value = newSelection
      
      // 添加重新排序動畫
      playAnimation('reorder', undefined, draggedIndex, targetIndex)
    }
  }
  
  onDragEnd()
}

// 選社方法
const addToSelection = (club: ClubCard) => {
  if (selectedClubs.value.some(selected => selected.clubId === club.id)) {
    alert('已選擇此社團')
    return
  }
  
  const preference: ClubPreference = {
    id: `pref-${Date.now()}`,
    clubId: club.id,
    clubName: club.name,
    clubCategory: club.category,
    clubImage: club.image,
    priority: selectedClubs.value.length + 1,
    isEligible: checkEligibility(club),
    eligibilityReason: checkEligibility(club) ? undefined : '不符合年級限制'
  }
  
  selectedClubs.value.push(preference)
  playAnimation('add', club.id)
}

const removeFromSelection = (index: number) => {
  const removedClub = selectedClubs.value[index]
  selectedClubs.value.splice(index, 1)
  
  // 重新編號
  selectedClubs.value.forEach((club, idx) => {
    club.priority = idx + 1
  })
  
  playAnimation('remove', removedClub.clubId)
}

// 檢查資格
const checkEligibility = (club: ClubCard): boolean => {
  // 簡化的資格檢查邏輯
  return true
}

// 檢查社團是否已被選中
const isClubSelected = (clubId: string): boolean => {
  return selectedClubs.value.some(selected => selected.clubId === clubId)
}

// 動畫效果
const playAnimation = (type: 'add' | 'remove' | 'reorder' | 'submit', clubId?: string, fromIndex?: number, toIndex?: number) => {
  // 這裡可以添加更複雜的動畫邏輯
  console.log(`Animation: ${type}`, { clubId, fromIndex, toIndex })
}

// 提交方法
const submitSelection = () => {
  if (!canSubmit.value) return
  showConfirmModal.value = true
}

const confirmSubmit = async () => {
  isSubmitting.value = true
  showConfirmModal.value = false
  
  try {
    // 準備提交的資料
    const selections = {
      club_choices: selectedClubs.value.map(club => parseInt(club.clubId))
    }
    
    // 提交到真實 API
    await clubApi.submitClubSelection(schoolId.value, parseInt(studentInfo.value.id), selections)
    
    playAnimation('submit')
    alert('志願提交成功！')
    
    // 導航到結果頁面或返回首頁
    goBack()
  } catch (error) {
    console.error('提交失敗:', error)
    alert('提交失敗，請重試')
  } finally {
    isSubmitting.value = false
  }
}

// 導航方法
const goBack = () => {
  // 返回學校首頁
  window.location.href = `/schools/${schoolId.value}/student`
}

// 資料載入
const loadData = async () => {
  try {
    isLoading.value = true
    error.value = null
    
    // 載入學校資訊和社團資料
    const [schoolData, clubsData] = await Promise.all([
      schoolApi.getPublicSchool(schoolId.value),
      clubApi.getClubs(schoolId.value)
    ])
    
    schoolInfo.value = schoolData
    realClubs.value = clubsData
    
    // 如果需要，也可以載入更完整的學生資訊
    // const currentStudentData = await studentApi.getStudent(schoolId.value, authStore.user.id)
    
  } catch (err) {
    console.error('載入資料失敗:', err)
    error.value = '載入資料失敗，請稍後再試'
  } finally {
    isLoading.value = false
  }
}

// 生命週期
onMounted(() => {
  // 檢查學生登入狀態
  if (!authStore.isStudent) {
    // 如果未登入，重導向到登入頁面
    window.location.href = `/schools/${schoolId.value}/student/login`
    return
  }
  
  // 載入資料
  loadData()
  
  // 初始化時間倒數
  updateTimeRemaining()
  const timer = setInterval(updateTimeRemaining, 60000) // 每分鐘更新
  
  onUnmounted(() => {
    clearInterval(timer)
  })
})

const updateTimeRemaining = () => {
  // 計算剩餘時間的邏輯
  const deadline = new Date('2024-09-15T23:59:59')
  const now = new Date()
  const diff = deadline.getTime() - now.getTime()
  
  if (diff > 0) {
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    timeRemaining.value = `${days}天${hours}小時`
  } else {
    timeRemaining.value = '已截止'
  }
}
</script>

<style scoped>
/* 拖拽相關樣式 */
.drag-over {
  @apply ring-2 ring-blue-400 ring-opacity-50;
}

.drag-placeholder {
  @apply opacity-50 scale-95 transform;
}

/* 動畫效果 */
.selection-enter-active,
.selection-leave-active {
  transition: all 0.3s ease;
}

.selection-enter-from {
  opacity: 0;
  transform: translateX(30px);
}

.selection-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

/* 響應式設計 */
@media (max-width: 768px) {
  .grid-cols-2 {
    @apply grid-cols-1;
  }
}
</style>