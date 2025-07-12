<template>
  <div class="space-y-6">
    <!-- 統計卡片 -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <!-- 總學校數 -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">總學校數</p>
            <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.totalSchools }}</p>
            <p class="text-sm text-green-600 mt-1">
              <i class="fas fa-arrow-up mr-1"></i>
              較上月 +{{ stats.schoolsGrowth }}
            </p>
          </div>
          <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
            <i class="fas fa-school text-blue-600 text-xl"></i>
          </div>
        </div>
      </div>

      <!-- 待審核申請 -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">待審核申請</p>
            <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.pendingApplications }}</p>
            <p class="text-sm text-amber-600 mt-1">
              <i class="fas fa-clock mr-1"></i>
              需要處理
            </p>
          </div>
          <div class="w-12 h-12 bg-amber-100 rounded-xl flex items-center justify-center">
            <i class="fas fa-hourglass-half text-amber-600 text-xl"></i>
          </div>
        </div>
      </div>

      <!-- 活躍用戶 -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">活躍用戶</p>
            <p class="text-3xl font-bold text-gray-900 mt-2">{{ stats.activeUsers.toLocaleString() }}</p>
            <p class="text-sm text-green-600 mt-1">
              <i class="fas fa-arrow-up mr-1"></i>
              較上週 +{{ stats.usersGrowth }}%
            </p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
            <i class="fas fa-users text-green-600 text-xl"></i>
          </div>
        </div>
      </div>

      <!-- 系統狀態 -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">系統狀態</p>
            <p class="text-xl font-bold text-green-600 mt-2 flex items-center">
              <span class="w-3 h-3 bg-green-500 rounded-full mr-2"></span>
              正常運行
            </p>
            <p class="text-sm text-gray-500 mt-1">
              運行時間 {{ stats.uptime }}
            </p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
            <i class="fas fa-server text-green-600 text-xl"></i>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要內容區域 -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- 待處理事項 -->
      <div class="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-200">
        <div class="p-6 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900">待處理事項</h3>
            <button class="text-sm text-blue-600 hover:text-blue-700">查看全部</button>
          </div>
        </div>
        <div class="p-6">
          <div class="space-y-4">
            <div v-for="task in pendingTasks" :key="task.id" 
                 class="flex items-start space-x-4 p-4 bg-gray-50 rounded-lg">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 rounded-full flex items-center justify-center"
                     :class="task.priority === 'high' ? 'bg-red-100 text-red-600' : 
                             task.priority === 'medium' ? 'bg-amber-100 text-amber-600' : 
                             'bg-gray-100 text-gray-600'">
                  <i :class="task.icon"></i>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900">{{ task.title }}</p>
                <p class="text-sm text-gray-500 mt-1">{{ task.description }}</p>
                <p class="text-xs text-gray-400 mt-2">{{ task.timeAgo }}</p>
              </div>
              <button class="flex-shrink-0 px-3 py-1 bg-blue-100 text-blue-700 text-xs rounded-full hover:bg-blue-200">
                處理
              </button>
            </div>
          </div>

          <!-- 空狀態 -->
          <div v-if="pendingTasks.length === 0" class="text-center py-8">
            <i class="fas fa-check-circle text-green-500 text-3xl mb-3"></i>
            <p class="text-gray-500">太棒了！沒有待處理事項</p>
          </div>
        </div>
      </div>

      <!-- 快速操作和最新活動 -->
      <div class="space-y-6">
        <!-- 快速操作 -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="p-6 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">快速操作</h3>
          </div>
          <div class="p-6">
            <div class="space-y-3">
              <router-link to="/admin/schools" 
                          class="flex items-center space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                  <i class="fas fa-school text-blue-600"></i>
                </div>
                <span class="font-medium text-gray-700">審核學校申請</span>
              </router-link>
              <router-link to="/admin/users" 
                          class="flex items-center space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                  <i class="fas fa-user-plus text-green-600"></i>
                </div>
                <span class="font-medium text-gray-700">管理用戶</span>
              </router-link>
              <button @click="showSystemSettings = true"
                      class="w-full flex items-center space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
                  <i class="fas fa-cog text-purple-600"></i>
                </div>
                <span class="font-medium text-gray-700">系統設定</span>
              </button>
              <button @click="exportData"
                      class="w-full flex items-center space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div class="w-8 h-8 bg-amber-100 rounded-lg flex items-center justify-center">
                  <i class="fas fa-download text-amber-600"></i>
                </div>
                <span class="font-medium text-gray-700">匯出資料</span>
              </button>
            </div>
          </div>
        </div>

        <!-- 最新活動 -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="p-6 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">最新活動</h3>
          </div>
          <div class="p-6">
            <div class="space-y-4">
              <div v-for="activity in recentActivities" :key="activity.id" 
                   class="flex items-start space-x-3">
                <div class="flex-shrink-0 w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-gray-900">{{ activity.action }}</p>
                  <p class="text-xs text-gray-500 mt-1">{{ activity.timeAgo }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 圖表區域 -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- 學校成長趨勢 -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">學校成長趨勢</h3>
        </div>
        <div class="p-6">
          <div class="h-64 flex items-center justify-center text-gray-500">
            <div class="text-center">
              <i class="fas fa-chart-line text-3xl mb-3"></i>
              <p>圖表元件開發中...</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 用戶活躍度 -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-200">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">用戶活躍度</h3>
        </div>
        <div class="p-6">
          <div class="h-64 flex items-center justify-center text-gray-500">
            <div class="text-center">
              <i class="fas fa-chart-bar text-3xl mb-3"></i>
              <p>圖表元件開發中...</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface Stats {
  totalSchools: number
  schoolsGrowth: number
  pendingApplications: number
  activeUsers: number
  usersGrowth: number
  uptime: string
}

interface PendingTask {
  id: string
  title: string
  description: string
  priority: 'high' | 'medium' | 'low'
  icon: string
  timeAgo: string
}

interface Activity {
  id: string
  action: string
  timeAgo: string
}

// 響應式數據
const stats = ref<Stats>({
  totalSchools: 0,
  schoolsGrowth: 0,
  pendingApplications: 0,
  activeUsers: 0,
  usersGrowth: 0,
  uptime: ''
})

const pendingTasks = ref<PendingTask[]>([])
const recentActivities = ref<Activity[]>([])
const showSystemSettings = ref(false)

// 載入統計數據
const loadStats = async () => {
  try {
    // TODO: 實際 API 呼叫
    stats.value = {
      totalSchools: 24,
      schoolsGrowth: 3,
      pendingApplications: 5,
      activeUsers: 1248,
      usersGrowth: 12.5,
      uptime: '15天 8小時'
    }
  } catch (error) {
    console.error('載入統計數據失敗:', error)
  }
}

// 載入待處理事項
const loadPendingTasks = async () => {
  try {
    // TODO: 實際 API 呼叫
    pendingTasks.value = [
      {
        id: '1',
        title: '新學校申請審核',
        description: '台北市立陽明高中申請加入系統',
        priority: 'high',
        icon: 'fas fa-school',
        timeAgo: '2 小時前'
      },
      {
        id: '2',
        title: '用戶權限調整',
        description: '3 位用戶請求權限升級',
        priority: 'medium',
        icon: 'fas fa-user-cog',
        timeAgo: '5 小時前'
      },
      {
        id: '3',
        title: '系統維護通知',
        description: '預定下週進行系統更新',
        priority: 'low',
        icon: 'fas fa-tools',
        timeAgo: '1 天前'
      }
    ]
  } catch (error) {
    console.error('載入待處理事項失敗:', error)
  }
}

// 載入最新活動
const loadRecentActivities = async () => {
  try {
    // TODO: 實際 API 呼叫
    recentActivities.value = [
      {
        id: '1',
        action: '核准了台中市立中山國中的申請',
        timeAgo: '30 分鐘前'
      },
      {
        id: '2',
        action: '新增了系統管理員 張小明',
        timeAgo: '2 小時前'
      },
      {
        id: '3',
        action: '完成了系統備份操作',
        timeAgo: '4 小時前'
      },
      {
        id: '4',
        action: '更新了系統安全設定',
        timeAgo: '6 小時前'
      }
    ]
  } catch (error) {
    console.error('載入最新活動失敗:', error)
  }
}

// 匯出資料
const exportData = () => {
  console.log('開始匯出資料...')
  // TODO: 實作匯出功能
}

// 初始化
onMounted(async () => {
  await Promise.all([
    loadStats(),
    loadPendingTasks(),
    loadRecentActivities()
  ])
})
</script>
