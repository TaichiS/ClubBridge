<template>
  <div class="p-6">
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900">隨機選社功能</h1>
      <p class="text-gray-600 mt-2">為所有尚未選社的學生模擬隨機選社</p>
    </div>

    <!-- 功能說明卡片 -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">功能說明</h2>
      <ul class="space-y-2 text-gray-600">
        <li class="flex items-start">
          <span class="text-blue-500 mr-2">•</span>
          此功能會為所有非特殊身份學生重新進行隨機選社
        </li>
        <li class="flex items-start">
          <span class="text-blue-500 mr-2">•</span>
          每個學生會隨機選取指定數量的社團作為志願序
        </li>
        <li class="flex items-start">
          <span class="text-blue-500 mr-2">•</span>
          可重複執行，每次都會覆蓋之前的選社記錄
        </li>
        <li class="flex items-start">
          <span class="text-blue-500 mr-2">•</span>
          主要用於測試系統功能和演示用途
        </li>
      </ul>
    </div>

    <!-- 警告訊息 -->
    <div class="bg-red-50 border-l-4 border-red-400 p-4 mb-6">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">注意事項</h3>
          <div class="mt-2 text-sm text-red-700">
            <p><strong>此操作會覆蓋所有非特殊身份學生的選社記錄！</strong></p>
            <p class="mt-1">執行前請確認：</p>
            <ul class="list-disc ml-5 mt-1">
              <li>這是測試環境或確實需要重置選社資料</li>
              <li>已經備份重要的學生選社記錄</li>
              <li>社團數量設定合理（建議不超過可用社團總數的 80%）</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- 設定表單 -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">隨機選社設定</h2>

      <div class="space-y-4">
        <div>
          <label for="clubCount" class="block text-sm font-medium text-gray-700 mb-2">
            每位學生選擇社團數量
          </label>
          <input
            id="clubCount"
            v-model.number="clubCount"
            type="number"
            min="1"
            max="50"
            class="w-full px-3 py-2 text-gray-600 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="輸入數量（如：20）"
          />
          <p class="text-sm text-gray-500 mt-1">
            建議設定為可用社團總數的 30%-50%，確保有足夠的選擇多樣性<br>
            <strong>注意：</strong>處理大量學生資料可能需要超過 60 秒的時間
          </p>
        </div>
      </div>
    </div>


    <!-- 執行按鈕 -->
    <div class="flex justify-between items-center">
      <div>
        <label class="flex items-center">
          <input
            v-model="confirmRisk"
            type="checkbox"
            class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
          />
          <span class="ml-2 text-sm text-gray-700">
            我了解此操作的風險，確認要執行隨機選社功能
          </span>
        </label>
      </div>

      <div>
        <button
          @click="executeRandomAssignment"
          :disabled="!confirmRisk || !clubCount || clubCount <= 0 || isExecuting"
          class="px-6 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <div v-if="isExecuting" class="flex items-center">
            <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
            執行中...（可能需要 1-3 分鐘）
          </div>
          <span v-else>執行隨機選社</span>
        </button>
      </div>
    </div>

    <!-- 執行日誌 -->
    <div v-if="executionLog.length > 0" class="mt-6 bg-white rounded-lg shadow-md p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-800">執行日誌</h2>
        <button
          @click="showDetailedLog = !showDetailedLog"
          class="px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors"
        >
          {{ showDetailedLog ? '隱藏詳細日誌' : '顯示詳細日誌' }}
        </button>
      </div>

      <div class="bg-gray-50 rounded-lg p-4 max-h-96 overflow-y-auto">
        <div v-for="(entry, index) in (showDetailedLog ? executionLog : executionLog.slice(-5))" :key="index" class="mb-2 last:mb-0">
          <div class="flex items-start space-x-2">
            <span class="text-xs text-gray-500 mt-1 w-16 flex-shrink-0">
              {{ formatTime(entry.timestamp) }}
            </span>
            <span
              :class="{
                'text-blue-600': entry.level === 'INFO',
                'text-yellow-600': entry.level === 'WARNING',
                'text-red-600': entry.level === 'ERROR',
                'text-green-600': entry.level === 'SUCCESS'
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

    <!-- 結果顯示 -->
    <div v-if="result" class="mt-6 bg-green-50 border-l-4 border-green-400 p-4">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-green-800">執行成功</h3>
          <div class="mt-2 text-sm text-green-700">
            <p>{{ result.message }}</p>
            <div class="mt-2 grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <span class="font-medium">處理學生：</span>
                {{ result.summary.total_students }} 位
              </div>
              <div>
                <span class="font-medium">每人選社數：</span>
                {{ result.summary.clubs_per_student }} 個
              </div>
              <div>
                <span class="font-medium">總選社記錄：</span>
                {{ result.summary.total_selections_created }} 筆
              </div>
              <div>
                <span class="font-medium">可用社團：</span>
                {{ result.summary.available_clubs }} 個
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 錯誤訊息 -->
    <div v-if="error" class="mt-6 bg-red-50 border-l-4 border-red-400 p-4">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">執行狀況</h3>
          <div class="mt-2 text-sm text-red-700">
            <p>{{ error }}</p>
            <p v-if="isExecuting" class="mt-2 text-amber-600">
              💡 執行時間較長是正常現象，請查看上方執行日誌了解進度
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { apiClient } from '@/api/client'

const route = useRoute()

// 響應式資料
const clubCount = ref<number>(20)
const confirmRisk = ref<boolean>(false)
const isExecuting = ref<boolean>(false)
const result = ref<any>(null)
const error = ref<string>('')
const showDetailedLog = ref<boolean>(false)

// 執行日誌
const executionLog = ref<Array<{
  timestamp: string,
  level: 'INFO' | 'WARNING' | 'ERROR' | 'SUCCESS',
  message: string
}>>([])

// 格式化時間
const formatTime = (timestamp: string) => {
  return new Date(timestamp).toLocaleTimeString('zh-TW', {
    hour12: false,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 添加日誌記錄
const addLog = (level: 'INFO' | 'WARNING' | 'ERROR' | 'SUCCESS', message: string) => {
  executionLog.value.push({
    timestamp: new Date().toISOString(),
    level,
    message
  })
}

// 執行隨機分配
const executeRandomAssignment = async () => {
  if (!confirmRisk.value || !clubCount.value || clubCount.value <= 0) {
    error.value = '請確認所有必要條件'
    return
  }

  isExecuting.value = true
  error.value = ''
  result.value = null
  executionLog.value = []
  
  let progressTimer: NodeJS.Timeout | null = null

  // 添加開始日誌
  addLog('INFO', '開始執行隨機選社功能...')
  addLog('INFO', `設定參數：每位學生選擇 ${clubCount.value} 個社團`)
  
  // 模擬進度更新（因為後端 API 不支援實時日誌回傳）
  progressTimer = setInterval(() => {
    const progressMessages = [
      '正在清除舊的選社記錄...',
      '正在為學生隨機選取社團...',
      '正在建立新的選社記錄...',
      '正在驗證資料完整性...',
      '即將完成處理...'
    ]
    const randomMessage = progressMessages[Math.floor(Math.random() * progressMessages.length)]
    addLog('INFO', `⏳ ${randomMessage}`)
  }, 15000) // 每15秒顯示一次進度訊息

  try {
    // 設置與 AllocationPage.vue 相同的超時時間（3分鐘）
    const response = await apiClient.getRawClient().post(`/api/schools/${route.params.schoolId}/club_selections/assign_random_clubs`, {
      club_count: clubCount.value
    }, {
      timeout: 180000 // 3 分鐘，與 allocationApi.allocateClubs 相同
    })

    // 清除進度計時器
    if (progressTimer) clearInterval(progressTimer)

    result.value = response.data

    // 添加成功日誌
    addLog('SUCCESS', '✅ 隨機選社執行完成！')
    if (result.value.summary) {
      addLog('INFO', `📊 成功處理 ${result.value.summary.total_students} 位學生`)
      addLog('INFO', `📝 總共建立 ${result.value.summary.total_selections_created} 筆選社記錄`)
      addLog('INFO', `🎯 使用 ${result.value.summary.available_clubs} 個可用社團`)
    }

    // 重置表單
    confirmRisk.value = false

  } catch (err: any) {
    // 清除進度計時器
    if (progressTimer) clearInterval(progressTimer)
    console.error('隨機選社執行錯誤:', err)

    if (err.code === 'ECONNABORTED' || err.message?.includes('timeout')) {
      addLog('WARNING', '⚠️ 執行時間超過預期（3分鐘），但處理可能仍在背景進行')
      addLog('INFO', '💡 建議稍後到「選社結果」頁面查看是否已完成')
      addLog('INFO', '❌ 請勿短時間內重複執行，避免資料衝突')
      error.value = '執行時間較長（超過3分鐘），處理可能仍在背景進行。請勿重複執行，稍後查看選社結果頁面確認狀態。'
    } else if (err.response?.status === 500) {
      addLog('ERROR', '❌ 伺服器內部錯誤，處理可能需要更多時間')
      addLog('INFO', '💡 建議稍後重新檢查或聯繫系統管理員')
      error.value = '伺服器處理中發生問題，請稍後重新檢查結果。'
    } else {
      const errorMessage = err.response?.data?.error || err.message || '執行失敗'
      addLog('ERROR', `❌ 執行失敗: ${errorMessage}`)
      error.value = errorMessage
    }
  } finally {
    isExecuting.value = false
  }
}

</script>