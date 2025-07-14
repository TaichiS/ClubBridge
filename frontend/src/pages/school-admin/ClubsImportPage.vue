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
        返回社團管理
      </button>
      <h1 class="text-3xl font-bold text-gray-900">社團資料批次匯入</h1>
      <p class="text-gray-600 mt-2">透過 Excel 檔案批次匯入社團資料</p>
    </div>

    <!-- 匯入流程指示 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
      <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">匯入流程</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="flex items-center space-x-3">
            <div class="w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-bold">1</div>
            <div>
              <h3 class="font-medium text-gray-900">下載範本</h3>
              <p class="text-sm text-gray-600">下載 Excel 範本檔案</p>
            </div>
          </div>
          <div class="flex items-center space-x-3">
            <div class="w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-bold">2</div>
            <div>
              <h3 class="font-medium text-gray-900">填寫資料</h3>
              <p class="text-sm text-gray-600">按照範本格式填寫社團資料</p>
            </div>
          </div>
          <div class="flex items-center space-x-3">
            <div class="w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-bold">3</div>
            <div>
              <h3 class="font-medium text-gray-900">上傳匯入</h3>
              <p class="text-sm text-gray-600">上傳檔案並檢查結果</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 下載範本區域 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
      <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">步驟 1：下載 Excel 範本</h2>
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-600 mb-2">請先下載標準的 Excel 範本檔案，確保欄位格式正確。</p>
            <div class="text-sm text-gray-500">
              <p>• 檔案格式：Excel (.xlsx)</p>
              <p>• 第一行為欄位標題，請勿修改</p>
              <p>• 資料從第二行開始填寫</p>
            </div>
          </div>
          <button
            @click="downloadTemplate"
            :disabled="isDownloading"
            class="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <i class="fas fa-download mr-2"></i>
            {{ isDownloading ? '下載中...' : '下載範本' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 欄位說明 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
      <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">步驟 2：欄位說明</h2>
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">欄位名稱</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">說明</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">範例</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">必填</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="field in fieldDescriptions" :key="field.name" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {{ field.name }}
                </td>
                <td class="px-6 py-4 text-sm text-gray-600">
                  {{ field.description }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ field.example }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="field.required ? 'text-red-600' : 'text-gray-400'">
                    {{ field.required ? '必填' : '選填' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- 文件上傳區域 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
      <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">步驟 3：上傳 Excel 檔案</h2>
        
        <!-- 拖拽上傳區域 -->
        <div 
          @drop.prevent="handleDrop"
          @dragover.prevent="isDragOver = true"
          @dragleave.prevent="isDragOver = false"
          :class="[
            'border-2 border-dashed rounded-lg p-8 text-center transition-colors',
            isDragOver ? 'border-blue-500 bg-blue-50' : 'border-gray-300',
            selectedFile ? 'bg-green-50 border-green-300' : ''
          ]"
        >
          <div v-if="!selectedFile">
            <i class="fas fa-cloud-upload-alt text-4xl text-gray-400 mb-4"></i>
            <p class="text-lg font-medium text-gray-900 mb-2">拖拽檔案到這裡，或點擊選擇檔案</p>
            <p class="text-gray-600 mb-4">支援 Excel 檔案格式（.xlsx, .xls）</p>
            <button 
              @click="triggerFileInput"
              class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              選擇檔案
            </button>
          </div>
          
          <div v-else class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <i class="fas fa-file-excel text-3xl text-green-600"></i>
              <div class="text-left">
                <p class="font-medium text-gray-900">{{ selectedFile.name }}</p>
                <p class="text-sm text-gray-600">{{ formatFileSize(selectedFile.size) }}</p>
              </div>
            </div>
            <button 
              @click="clearFile"
              class="text-red-600 hover:text-red-800"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
        </div>

        <input 
          ref="fileInput"
          type="file"
          accept=".xlsx,.xls"
          @change="handleFileSelect"
          class="hidden"
        />

        <!-- 上傳按鈕 -->
        <div class="mt-6 flex justify-center">
          <button
            @click="uploadFile"
            :disabled="!selectedFile || isUploading"
            class="px-8 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <i class="fas fa-upload mr-2"></i>
            {{ isUploading ? '上傳中...' : '開始匯入' }}
          </button>
        </div>

        <!-- 上傳進度 -->
        <div v-if="isUploading" class="mt-4">
          <div class="bg-gray-200 rounded-full h-2">
            <div 
              class="bg-blue-600 h-2 rounded-full transition-all duration-300"
              :style="{ width: `${uploadProgress}%` }"
            ></div>
          </div>
          <p class="text-center text-sm text-gray-600 mt-2">
            上傳進度：{{ uploadProgress }}%
          </p>
        </div>
      </div>
    </div>

    <!-- 匯入結果 -->
    <div v-if="importResult" class="bg-white rounded-lg shadow-sm border border-gray-200">
      <div class="p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">匯入結果</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
          <div class="text-center p-4 bg-green-50 rounded-lg">
            <div class="text-2xl font-bold text-green-600">{{ importResult.imported || 0 }}</div>
            <div class="text-sm text-gray-600">成功匯入</div>
          </div>
          <div class="text-center p-4 bg-red-50 rounded-lg">
            <div class="text-2xl font-bold text-red-600">{{ importResult.errors?.length || 0 }}</div>
            <div class="text-sm text-gray-600">匯入失敗</div>
          </div>
          <div class="text-center p-4 bg-blue-50 rounded-lg">
            <div class="text-2xl font-bold text-blue-600">{{ (importResult.imported || 0) + (importResult.errors?.length || 0) }}</div>
            <div class="text-sm text-gray-600">總計處理</div>
          </div>
        </div>

        <!-- 成功訊息 -->
        <div v-if="importResult.imported > 0 && (!importResult.errors || importResult.errors.length === 0)" class="mb-6">
          <div class="bg-green-50 rounded-lg p-4 border border-green-200">
            <div class="flex items-center">
              <i class="fas fa-check-circle text-green-600 text-lg mr-3"></i>
              <div>
                <h3 class="text-lg font-medium text-green-800">匯入完成</h3>
                <p class="text-sm text-green-700">成功匯入 {{ importResult.imported }} 筆社團資料，無任何錯誤。</p>
              </div>
            </div>
          </div>
        </div>

        <!-- 錯誤列表 -->
        <div v-if="importResult.errors && importResult.errors.length > 0" class="mb-6">
          <h3 class="text-lg font-medium text-red-600 mb-3">匯入錯誤詳情</h3>
          <div class="bg-red-50 rounded-lg p-4 max-h-60 overflow-y-auto border border-red-200">
            <ul class="space-y-2">
              <li v-for="(error, index) in importResult.errors" :key="index" class="text-sm text-red-700">
                • {{ error }}
              </li>
            </ul>
          </div>
        </div>

        <!-- 操作按鈕 -->
        <div class="flex space-x-4">
          <button
            @click="resetImport"
            class="px-6 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700"
          >
            重新匯入
          </button>
          <button
            @click="goBack"
            class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            返回社團管理
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useClubStore } from '@/stores/club'

const router = useRouter()
const route = useRoute()
const clubStore = useClubStore()

// 從路由獲取學校 ID
const schoolId = computed(() => parseInt(route.params.schoolId as string))

// 響應式狀態
const selectedFile = ref<File | null>(null)
const isDragOver = ref(false)
const isUploading = ref(false)
const isDownloading = ref(false)
const uploadProgress = ref(0)
const importResult = ref<{
  imported: number
  errors: string[]
  preview?: any[]
} | null>(null)

// 檔案輸入引用
const fileInput = ref<HTMLInputElement>()

// 欄位說明
const fieldDescriptions = [
  { name: '類別', description: '社團類別（如：體育、藝文、學術等）', example: '體育', required: true },
  { name: '編號', description: '社團編號（唯一識別）', example: 'C001', required: true },
  { name: '社團名稱', description: '社團的完整名稱', example: '簃球社', required: true },
  { name: '指導老師', description: '指導老師姓名', example: '王大明', required: true },
  { name: '簡介', description: '社團簡介說明（最多500字）', example: '學習簃球基本技巧、參加比賽', required: true },
  { name: '最大人數', description: '社團最大招收人數', example: '30', required: true },
  { name: '上課地點', description: '上課地點', example: '體育館', required: true },
  { name: '雨天地點', description: '雨天替代地點', example: '教室A101', required: false },
  { name: '備註', description: '其他說明事項', example: '需自備運動鞘', required: false },
  { name: '條件一', description: '限制條件（男生=1、女生=2、無限制=0）', example: '0', required: false },
  { name: '條件二', description: '限制條件（高中=1、國中=2、無限制=0）', example: '0', required: false },
  { name: '條件三', description: '自定義條件欄位', example: '', required: false },
  { name: '社團老師 Email', description: '社團老師的電子信箱（用於登入識別）', example: 'teacher@school.edu', required: false }
]

// 方法
const goBack = () => {
  router.push(`/schools/${schoolId.value}/admin/clubs`)
}

const downloadTemplate = async () => {
  isDownloading.value = true
  try {
    // 直接下載實際的 xlsx 範本檔案
    const link = document.createElement('a')
    link.href = '/社團資料匯入範本.xlsx'
    link.download = '社團資料匯入範本.xlsx'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  } catch (error) {
    console.error('下載範本失敗:', error)
    alert('下載範本失敗，請稍後再試')
  } finally {
    isDownloading.value = false
  }
}

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    selectedFile.value = target.files[0]
  }
}

const handleDrop = (event: DragEvent) => {
  isDragOver.value = false
  if (event.dataTransfer?.files && event.dataTransfer.files[0]) {
    const file = event.dataTransfer.files[0]
    if (file.name.endsWith('.xlsx') || file.name.endsWith('.xls')) {
      selectedFile.value = file
    } else {
      alert('請選擇 Excel 檔案（.xlsx 或 .xls）')
    }
  }
}

const clearFile = () => {
  selectedFile.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const formatFileSize = (bytes: number) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const uploadFile = async () => {
  if (!selectedFile.value || !schoolId.value) return

  isUploading.value = true
  uploadProgress.value = 0
  importResult.value = null

  try {
    const result = await clubStore.importClubs(
      schoolId.value,
      selectedFile.value
    )
    
    importResult.value = result
    
    // 匯入成功後重新載入社團列表
    if (result.imported > 0) {
      await clubStore.fetchClubs(schoolId.value)
    }
    
  } catch (error: any) {
    console.error('匯入失敗:', error)
    importResult.value = {
      imported: 0,
      errors: [error.message || '匯入過程中發生錯誤']
    }
  } finally {
    isUploading.value = false
    uploadProgress.value = 100
  }
}

const resetImport = () => {
  selectedFile.value = null
  importResult.value = null
  uploadProgress.value = 0
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// 生命週期
onMounted(() => {
  // 頁面載入時的初始化邏輯
})
</script>
