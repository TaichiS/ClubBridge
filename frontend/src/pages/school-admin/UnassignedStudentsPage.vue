<template>
  <div class="max-w-7xl mx-auto px-6 py-8">
    <!-- 頁面標題 -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">衰運學生處理</h1>
      <p class="mt-2 text-gray-600">
        手動分配未能透過自動分發獲得社團的學生
      </p>
    </div>

    <!-- 統計卡片 -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <svg class="h-8 w-8 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/>
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">未分配學生</p>
            <p class="text-2xl font-semibold text-gray-900">{{ unassignedStudents.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <svg class="h-8 w-8 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">可用社團</p>
            <p class="text-2xl font-semibold text-gray-900">{{ availableClubs.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <svg class="h-8 w-8 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">可用空位</p>
            <p class="text-2xl font-semibold text-gray-900">{{ totalAvailableSpots }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <svg class="h-8 w-8 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">本次已分配</p>
            <p class="text-2xl font-semibold text-gray-900">{{ assignedCount }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 批量分配區 -->
    <div v-if="unassignedStudents.length > 0" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">批量分配</h2>

      <div class="flex flex-col sm:flex-row gap-4 items-end">
        <div class="flex-1">
          <label class="block text-sm font-medium text-gray-700 mb-2">選擇社團</label>
          <select
            v-model="bulkAssignmentClubId"
            class="text-gray-600 w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">請選擇社團</option>
            <option
              v-for="club in availableClubs"
              :key="club.id"
              :value="club.id"
              :disabled="club.available_spots <= 0"
            >
              {{ club.name }} (剩餘 {{ club.available_spots }} 個名額, {{ getEligibleStudentsCount(club) }} 位符合條件)
            </option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">分配人數</label>
          <input
            v-model.number="bulkAssignmentCount"
            type="number"
            :min="1"
            :max="maxBulkAssignmentCount"
            class="text-gray-600 w-24 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="人數"
          />
        </div>

        <button
          @click="performBulkAssignment"
          :disabled="!canPerformBulkAssignment"
          class="px-6 py-2 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
        >
          批量分配
        </button>
      </div>

      <p v-if="bulkAssignmentClubId" class="text-sm text-gray-500 mt-2">
        將從 {{ maxBulkAssignmentCount }} 位符合條件的學生中隨機選取 {{ Math.min(bulkAssignmentCount || 1, maxBulkAssignmentCount) }} 位分配到該社團
      </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <!-- 未分配學生列表 -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-900">未分配學生</h2>
            <button
              @click="refreshData"
              :disabled="isLoading"
              class="p-2 text-gray-400 hover:text-gray-600 transition-colors"
              title="重新整理"
            >
              <svg
                class="h-5 w-5"
                :class="{ 'animate-spin': isLoading }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="p-6">
          <div v-if="isLoading" class="text-center py-8">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
            <p class="text-gray-500 mt-2">載入中...</p>
          </div>

          <div v-else-if="unassignedStudents.length === 0" class="text-center py-8">
            <svg class="mx-auto h-12 w-12 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">太好了！</h3>
            <p class="mt-1 text-sm text-gray-500">所有學生都已成功分配到社團</p>
          </div>

          <div v-else class="space-y-4">
            <div
              v-for="student in unassignedStudents"
              :key="student.id"
              class="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
            >
              <div class="flex-1">
                <div class="flex items-center space-x-3">
                  <div class="flex-shrink-0">
                    <div class="h-10 w-10 bg-red-100 rounded-full flex items-center justify-center">
                      <span class="text-sm font-medium text-red-700">{{ student.name.slice(-1) }}</span>
                    </div>
                  </div>
                  <div>
                    <h3 class="text-sm font-medium text-gray-900">{{ student.name }}</h3>
                    <p class="text-sm text-gray-500">
                      {{ student.grade }}年{{ student.class_name }}班 座號{{ student.seat_number }}
                    </p>
                  </div>
                </div>
              </div>

              <div class="flex items-center space-x-3">
                <select
                  v-model="student.selectedClubId"
                  class="text-gray-600 px-3 py-1 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  @change="updateSelectedClub(student)"
                >
                  <option value="">選擇社團</option>
                  <option
                    v-for="club in getAvailableClubsForStudent(student)"
                    :key="club.id"
                    :value="club.id"
                  >
                    {{ club.name }} ({{ club.available_spots }})
                  </option>
                </select>

                <button
                  @click="assignStudentToClub(student)"
                  :disabled="!student.selectedClubId || isAssigning"
                  class="px-3 py-1 text-sm bg-green-600 text-white rounded-md hover:bg-green-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
                >
                  {{ isAssigning ? '分配中...' : '分配' }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 可用社團列表 -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900">可用社團</h2>
        </div>

        <div class="p-6">
          <div v-if="availableClubs.length === 0" class="text-center py-8">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-4.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 009.586 13H7"/>
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">沒有可用社團</h3>
            <p class="mt-1 text-sm text-gray-500">所有社團都已滿額</p>
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="club in availableClubs"
              :key="club.id"
              class="flex items-center justify-between p-4 border border-gray-200 rounded-lg"
            >
              <div class="flex-1">
                <h3 class="text-sm font-medium text-gray-900">{{ club.name }}</h3>
                <p class="text-sm text-gray-500">{{ club.category }} | {{ club.teacher_name }}</p>
                <p class="text-xs text-gray-400 mt-1">{{ club.location }}</p>
              </div>

              <div class="text-right">
                <span class="text-sm font-semibold text-green-600">{{ club.available_spots }}</span>
                <span class="text-xs text-gray-500">/ {{ club.max_members }}</span>
                <p class="text-xs text-gray-400">剩餘名額</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { unassignedStudentsApi } from '@/api/unassignedStudents'

const route = useRoute()

// 響應式資料
const isLoading = ref(false)
const isAssigning = ref(false)
const assignedCount = ref(0)

// 學生和社團資料
const unassignedStudents = ref<any[]>([])
const availableClubs = ref<any[]>([])

// 批量分配
const bulkAssignmentClubId = ref('')
const bulkAssignmentCount = ref(1)

// 計算屬性
const totalAvailableSpots = computed(() => {
  return availableClubs.value.reduce((sum, club) => sum + club.available_spots, 0)
})

const maxBulkAssignmentCount = computed(() => {
  const selectedClub = availableClubs.value.find(club => club.id === bulkAssignmentClubId.value)
  if (!selectedClub) return 0

  // 計算符合條件的學生數量
  const eligibleStudentsCount = unassignedStudents.value.filter(student => {
    // 檢查社團條件限制
    if (selectedClub.condition1 && selectedClub.condition1 !== 0 &&
        student.condition1 !== selectedClub.condition1) return false
    if (selectedClub.condition2 && selectedClub.condition2 !== 0 &&
        student.condition2 !== selectedClub.condition2) return false
    if (selectedClub.condition3 && selectedClub.condition3 !== 0 &&
        student.condition3 !== selectedClub.condition3) return false

    return true
  }).length

  return Math.min(selectedClub.available_spots, eligibleStudentsCount)
})

const canPerformBulkAssignment = computed(() => {
  return bulkAssignmentClubId.value &&
         bulkAssignmentCount.value > 0 &&
         bulkAssignmentCount.value <= maxBulkAssignmentCount.value &&
         !isAssigning.value
})

// 方法
const refreshData = async () => {
  isLoading.value = true
  try {
    const schoolId = Number(route.params.schoolId)
    const [studentsData, clubsData] = await Promise.all([
      unassignedStudentsApi.getUnassignedStudents(schoolId),
      unassignedStudentsApi.getAvailableClubs(schoolId)
    ])

    unassignedStudents.value = studentsData.map(student => ({
      ...student,
      selectedClubId: ''
    }))
    availableClubs.value = clubsData

  } catch (error) {
    console.error('載入資料失敗:', error)
  } finally {
    isLoading.value = false
  }
}

const getAvailableClubsForStudent = (student: any) => {
  return availableClubs.value.filter(club => {
    // 檢查社團條件限制
    if (club.condition1 && club.condition1 !== student.condition1) return false
    if (club.condition2 && club.condition2 !== student.condition2) return false
    if (club.condition3 && club.condition3 !== student.condition3) return false

    return club.available_spots > 0
  })
}

const getEligibleStudentsCount = (club: any) => {
  return unassignedStudents.value.filter(student => {
    // 檢查社團條件限制
    if (club.condition1 && club.condition1 !== 0 &&
        student.condition1 !== club.condition1) return false
    if (club.condition2 && club.condition2 !== 0 &&
        student.condition2 !== club.condition2) return false
    if (club.condition3 && club.condition3 !== 0 &&
        student.condition3 !== club.condition3) return false

    return true
  }).length
}

const updateSelectedClub = (student: any) => {
  // 可以在這裡添加額外的邏輯
}

const assignStudentToClub = async (student: any) => {
  if (!student.selectedClubId) return

  isAssigning.value = true
  try {
    const schoolId = Number(route.params.schoolId)
    await unassignedStudentsApi.assignStudentToClub(
      schoolId,
      student.id,
      student.selectedClubId
    )

    // 更新本地狀態
    unassignedStudents.value = unassignedStudents.value.filter(s => s.id !== student.id)

    // 更新社團可用名額
    const club = availableClubs.value.find(c => c.id === student.selectedClubId)
    if (club) {
      club.available_spots--
      if (club.available_spots <= 0) {
        availableClubs.value = availableClubs.value.filter(c => c.id !== club.id)
      }
    }

    assignedCount.value++

  } catch (error: any) {
    console.error('分配失敗:', error)
    alert(`分配失敗: ${error.message}`)
  } finally {
    isAssigning.value = false
  }
}

const performBulkAssignment = async () => {
  if (!canPerformBulkAssignment.value) return

  isAssigning.value = true
  try {
    const schoolId = Number(route.params.schoolId)

    // 找到選定的社團
    const selectedClub = availableClubs.value.find(c => c.id === bulkAssignmentClubId.value)
    if (!selectedClub) {
      throw new Error('找不到選定的社團')
    }

    // 過濾符合條件的學生
    const eligibleStudents = unassignedStudents.value.filter(student => {
      // 檢查社團條件限制
      if (selectedClub.condition1 && selectedClub.condition1 !== 0 &&
          student.condition1 !== selectedClub.condition1) return false
      if (selectedClub.condition2 && selectedClub.condition2 !== 0 &&
          student.condition2 !== selectedClub.condition2) return false
      if (selectedClub.condition3 && selectedClub.condition3 !== 0 &&
          student.condition3 !== selectedClub.condition3) return false

      return true
    })

    // 檢查是否有足夠符合條件的學生
    if (eligibleStudents.length === 0) {
      throw new Error('沒有符合該社團條件的學生')
    }

    if (eligibleStudents.length < bulkAssignmentCount.value) {
      throw new Error(`只有 ${eligibleStudents.length} 位學生符合條件，但要分配 ${bulkAssignmentCount.value} 位`)
    }

    // 從符合條件的學生中隨機選取
    const studentsToAssign = [...eligibleStudents]
      .sort(() => 0.5 - Math.random())
      .slice(0, bulkAssignmentCount.value)

    // 批量分配
    await Promise.all(
      studentsToAssign.map(student =>
        unassignedStudentsApi.assignStudentToClub(
          schoolId,
          student.id,
          bulkAssignmentClubId.value
        )
      )
    )

    // 更新本地狀態
    const assignedStudentIds = new Set(studentsToAssign.map(s => s.id))
    unassignedStudents.value = unassignedStudents.value.filter(s => !assignedStudentIds.has(s.id))

    // 更新社團可用名額
    const club = availableClubs.value.find(c => c.id === bulkAssignmentClubId.value)
    if (club) {
      club.available_spots -= studentsToAssign.length
      if (club.available_spots <= 0) {
        availableClubs.value = availableClubs.value.filter(c => c.id !== club.id)
      }
    }

    assignedCount.value += studentsToAssign.length

    // 重置批量分配表單
    bulkAssignmentClubId.value = ''
    bulkAssignmentCount.value = 1

  } catch (error: any) {
    console.error('批量分配失敗:', error)
    alert(`批量分配失敗: ${error.message}`)
  } finally {
    isAssigning.value = false
  }
}

// 組件掛載時載入資料
onMounted(() => {
  refreshData()
})
</script>