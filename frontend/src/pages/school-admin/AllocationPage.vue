<template>
  <div class="max-w-6xl mx-auto px-6 py-8">
    <!-- 頁面標題 -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">社團分發</h1>
      <p class="mt-2 text-gray-600">
        自動依照學生志願序進行社團分發，特殊學生將優先分配
      </p>
    </div>

    <!-- 分發狀態卡片 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
      <div class="flex items-center justify-between mb-6">
        <div>
          <h2 class="text-xl font-semibold text-gray-900">分發狀態</h2>
          <p class="text-sm text-gray-500 mt-1">檢查系統準備狀況</p>
        </div>
        <div class="flex items-center space-x-2">
          <div 
            v-if="allocationStatus === 'loading'"
            class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"
          ></div>
          <span 
            :class="{
              'bg-green-100 text-green-800': allocationStatus === 'ready',
              'bg-yellow-100 text-yellow-800': allocationStatus === 'warning',
              'bg-red-100 text-red-800': allocationStatus === 'error',
              'bg-blue-100 text-blue-800': allocationStatus === 'running'
            }"
            class="px-3 py-1 rounded-full text-sm font-medium"
          >
            {{ getStatusText() }}
          </span>
        </div>
      </div>

      <!-- 系統檢查結果 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="bg-gray-50 rounded-lg p-4">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-gray-900">學生人數</span>
            <span class="text-lg font-semibold text-blue-600">
              {{ systemCheck.studentCount || 0 }}
            </span>
          </div>
        </div>
        
        <div class="bg-gray-50 rounded-lg p-4">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-gray-900">社團數量</span>
            <span class="text-lg font-semibold text-green-600">
              {{ systemCheck.clubCount || 0 }}
            </span>
          </div>
        </div>
        
        <div class="bg-gray-50 rounded-lg p-4">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-gray-900">選社記錄</span>
            <span class="text-lg font-semibold text-purple-600">
              {{ systemCheck.selectionCount || 0 }}
            </span>
          </div>
        </div>
      </div>

      <!-- 警告訊息 -->
      <div v-if="systemCheck.warnings && systemCheck.warnings.length > 0" class="mb-6">
        <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800">注意事項</h3>
              <div class="mt-2 text-sm text-yellow-700">
                <ul class="list-disc list-inside space-y-1">
                  <li v-for="warning in systemCheck.warnings" :key="warning">
                    {{ warning }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 錯誤訊息 -->
      <div v-if="systemCheck.errors && systemCheck.errors.length > 0" class="mb-6">
        <div class="bg-red-50 border-l-4 border-red-400 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">錯誤</h3>
              <div class="mt-2 text-sm text-red-700">
                <ul class="list-disc list-inside space-y-1">
                  <li v-for="error in systemCheck.errors" :key="error">
                    {{ error }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分發操作區 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
      <h2 class="text-xl font-semibold text-gray-900 mb-4">執行分發</h2>
      
      <div class="flex items-center justify-between">
        <div class="flex-1">
          <p class="text-gray-600 mb-2">
            點擊下方按鈕開始自動分發流程。系統將依照以下順序進行：
          </p>
          <ol class="text-sm text-gray-500 list-decimal list-inside space-y-1">
            <li>特殊學生優先分配（不受人數限制）</li>
            <li>一般學生依志願序分發</li>
            <li>隨機公平分配同志願的學生</li>
            <li>產生分發結果與統計</li>
          </ol>
          <p class="text-sm text-amber-600 mt-3 font-medium">
            ⏱️ 分發過程可能需要 1-3 分鐘，請耐心等候
          </p>
        </div>
        
        <div class="ml-6">
          <button
            @click="showConfirmDialog = true"
            :disabled="!canStartAllocation || isAllocating"
            class="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
          >
            <div v-if="isAllocating" class="flex items-center">
              <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
              分發中... (可能需要 1-3 分鐘)
            </div>
            <span v-else>開始分發</span>
          </button>
        </div>
      </div>
    </div>

    <!-- 分發日誌 -->
    <div v-if="allocationLog.length > 0" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-gray-900">分發日誌</h2>
        <button
          @click="showDetailedLog = !showDetailedLog"
          class="px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors"
        >
          {{ showDetailedLog ? '隱藏詳細日誌' : '顯示詳細日誌' }}
        </button>
      </div>
      
      <div class="bg-gray-50 rounded-lg p-4 max-h-96 overflow-y-auto">
        <div v-for="(entry, index) in (showDetailedLog ? allocationLog : allocationLog.slice(-5))" :key="index" class="mb-2 last:mb-0">
          <div class="flex items-start space-x-2">
            <span class="text-xs text-gray-500 mt-1 w-16 flex-shrink-0">
              {{ formatTime(entry.timestamp) }}
            </span>
            <span 
              :class="{
                'text-blue-600': entry.level === 'INFO',
                'text-yellow-600': entry.level === 'WARNING',
                'text-red-600': entry.level === 'ERROR'
              }"
              class="text-xs font-mono flex-shrink-0 w-16"
            >
              [{{ entry.level }}]
            </span>
            <span class="text-sm text-gray-700 flex-1">{{ entry.message }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 確認對話框 -->
    <div v-if="showConfirmDialog" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
        <div class="p-6">
          <div class="flex items-center mb-4">
            <div class="flex-shrink-0">
              <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/>
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-lg font-medium text-gray-900">確認開始分發</h3>
            </div>
          </div>
          
          <div class="mb-4">
            <div v-if="hasExistingAllocations" class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
              <div class="flex items-start">
                <svg class="h-5 w-5 text-red-400 mt-0.5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                </svg>
                <div>
                  <h4 class="text-sm font-medium text-red-800">⚠️ 注意：將覆蓋既有分發結果</h4>
                  <p class="text-sm text-red-700 mt-1">
                    系統偵測到已有學生分發記錄，執行新分發將完全清除現有結果
                  </p>
                </div>
              </div>
            </div>

            <p class="text-sm text-gray-500 mb-2">
              此操作將：
            </p>
            <ul class="text-sm text-gray-600 list-disc list-inside space-y-1">
              <li v-if="hasExistingAllocations" class="text-red-600 font-medium">清除所有現有的分發結果</li>
              <li v-else>清除之前的分發結果（如果有的話）</li>
              <li>重新進行社團分配</li>
              <li>無法復原已執行的分發</li>
            </ul>
            <p class="text-sm mt-3 font-medium" :class="hasExistingAllocations ? 'text-red-600' : 'text-amber-600'">
              {{ hasExistingAllocations ? '⚠️ 此操作將無法復原，請謹慎確認' : '請確認要繼續執行分發操作' }}
            </p>
          </div>

          <div class="flex justify-end space-x-3">
            <button
              @click="showConfirmDialog = false"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              取消
            </button>
            <button
              @click="startAllocation"
              :class="hasExistingAllocations ? 
                'px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700' :
                'px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700'"
            >
              {{ hasExistingAllocations ? '確認覆蓋並執行' : '確認執行' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { allocationApi } from '@/api/allocation'

const route = useRoute()

// 響應式資料
const allocationStatus = ref<'loading' | 'ready' | 'warning' | 'error' | 'running'>('loading')
const isAllocating = ref(false)
const showConfirmDialog = ref(false)
const showDetailedLog = ref(false)
const hasExistingAllocations = ref(false)

// 系統檢查結果
const systemCheck = ref({
  studentCount: 0,
  clubCount: 0,
  selectionCount: 0,
  warnings: [] as string[],
  errors: [] as string[]
})

// 分發日誌
const allocationLog = ref<Array<{
  timestamp: string,
  level: 'INFO' | 'WARNING' | 'ERROR',
  message: string
}>>([])

// 計算屬性
const canStartAllocation = computed(() => {
  return allocationStatus.value === 'ready' || allocationStatus.value === 'warning'
})

// 方法
const getStatusText = () => {
  switch (allocationStatus.value) {
    case 'loading':
      return '檢查中...'
    case 'ready':
      return '準備就緒'
    case 'warning':
      return '注意事項'
    case 'error':
      return '發生錯誤'
    case 'running':
      return '分發中...'
    default:
      return '未知狀態'
  }
}

const formatTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleTimeString('zh-TW', { 
    hour12: false,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const checkSystemStatus = async () => {
  try {
    allocationStatus.value = 'loading'
    const schoolId = Number(route.params.schoolId)
    
    // 呼叫 API 檢查系統狀態
    const result = await allocationApi.checkSystemStatus(schoolId)
    
    systemCheck.value = {
      studentCount: result.studentCount,
      clubCount: result.clubCount,
      selectionCount: result.selectionCount,
      warnings: result.warnings,
      errors: result.errors
    }

    // 檢查是否有既有分發記錄
    hasExistingAllocations.value = result.warnings.some(warning => 
      warning.includes('已存在分發記錄')
    )

    if (systemCheck.value.errors.length > 0) {
      allocationStatus.value = 'error'
    } else if (systemCheck.value.warnings.length > 0) {
      allocationStatus.value = 'warning'
    } else {
      allocationStatus.value = 'ready'
    }

  } catch (error: any) {
    console.error('系統檢查失敗:', error)
    allocationStatus.value = 'error'
    systemCheck.value.errors = [error.message || '無法連接到伺服器，請檢查網路連線']
  }
}

const startAllocation = async () => {
  showConfirmDialog.value = false
  isAllocating.value = true
  allocationStatus.value = 'running'
  allocationLog.value = []
  
  try {
    const schoolId = Number(route.params.schoolId)
    
    // 呼叫分發 API
    const result = await allocationApi.allocateClubs(schoolId)
    
    // 處理分發結果
    if (result.success) {
      allocationLog.value = result.detailed_log || []
      
      // 顯示成功訊息
      allocationLog.value.push({
        timestamp: new Date().toISOString(),
        level: 'INFO',
        message: `分發完成！共分配 ${result.statistics?.assigned_students || 0} 位學生`
      })
      
      allocationStatus.value = 'ready'
    } else {
      // 處理分發失敗
      allocationLog.value.push({
        timestamp: new Date().toISOString(),
        level: 'ERROR',
        message: `分發失敗: ${result.error}`
      })
      
      allocationStatus.value = 'error'
    }
    
  } catch (error: any) {
    console.error('分發過程發生錯誤:', error)
    
    allocationLog.value.push({
      timestamp: new Date().toISOString(),
      level: 'ERROR',
      message: `系統錯誤: ${error.message || '未知錯誤'}`
    })
    
    allocationStatus.value = 'error'
  } finally {
    isAllocating.value = false
  }
}

// 組件掛載時檢查系統狀態
onMounted(() => {
  checkSystemStatus()
})
</script>