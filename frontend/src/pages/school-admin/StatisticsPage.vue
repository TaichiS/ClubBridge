<template>
  <div class="p-8">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">選社即時統計</h1>
      <p class="text-gray-600">查看選社期間的統計數據和熱門社團狀態</p>
    </div>

    <!-- Tab 導航 -->
    <div class="mb-8">
      <nav class="flex space-x-8">
        <button
          @click="activeTab = 'daily'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'daily' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          每日選社統計
        </button>
        <button
          @click="activeTab = 'popular'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'popular' 
              ? 'border-blue-500 text-blue-600' 
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          熱門社團分析
        </button>
      </nav>
    </div>

    <!-- 每日選社統計 Tab -->
    <div v-show="activeTab === 'daily'">
      <!-- 統計卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-blue-100">
            <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm text-gray-500">總選社人數</p>
            <p class="text-2xl font-semibold text-gray-900">{{ statistics.totalRegistrations || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-green-100">
            <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm text-gray-500">今日選社人數</p>
            <p class="text-2xl font-semibold text-gray-900">{{ statistics.todayRegistrations || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-purple-100">
            <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm text-gray-500">選社完成率</p>
            <p class="text-2xl font-semibold text-gray-900">{{ statistics.completionRate || 0 }}%</p>
          </div>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-orange-100">
            <svg class="h-6 w-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm text-gray-500">平均每日選社</p>
            <p class="text-2xl font-semibold text-gray-900">{{ statistics.averageDaily || 0 }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 圖表區域 -->
    <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
      <div class="mb-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-2">每日選社人數趨勢</h2>
        <p class="text-gray-600">顯示選社期間每日的報名人數變化</p>
      </div>

      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>

      <div v-else-if="error" class="text-center py-8">
        <p class="text-red-600 mb-4">{{ error }}</p>
        <button @click="loadData" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          重新載入
        </button>
      </div>

      <div v-else class="h-96">
        <Bar 
          :data="chartData" 
          :options="chartOptions" 
          class="w-full h-full"
        />
      </div>
    </div>

    <!-- 詳細數據表格 -->
    <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200 mt-8">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">詳細數據</h3>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                日期
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                選社人數
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                累計人數
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                完成率
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="(data, index) in dailyStats" :key="index">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ formatDate(data.date) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ data.count }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ data.cumulative }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ Math.round(data.completionRate) }}%
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    </div>

    <!-- 熱門社團分析 Tab -->
    <div v-show="activeTab === 'popular'">
      <!-- 熱門社團統計卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-red-100">
              <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.5-7 0 0 .5 0 1.5.5C14.5 6.5 17 7 17 7l1.657 1.657z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm text-gray-500">熱門社團數</p>
              <p class="text-2xl font-semibold text-gray-900">{{ popularStats.totalPopularClubs || 0 }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-yellow-100">
              <svg class="h-6 w-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm text-gray-500">最熱門社團第一志願</p>
              <p class="text-2xl font-semibold text-gray-900">{{ topClub?.first_choice_count || 0 }}</p>
            </div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div class="flex items-center">
            <div class="p-3 rounded-full bg-purple-100">
              <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
            <div class="ml-4">
              <p class="text-sm text-gray-500">總社團數</p>
              <p class="text-2xl font-semibold text-gray-900">{{ popularStats.allClubs?.length || 0 }}</p>
            </div>
          </div>
        </div>
      </div>

      <div v-if="popularLoading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>

      <div v-else-if="popularError" class="text-center py-8">
        <p class="text-red-600 mb-4">{{ popularError }}</p>
        <button @click="loadPopularData" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          重新載入
        </button>
      </div>

      <!-- 熱門社團列表 -->
      <div v-else class="space-y-6">
        <!-- 熱門社團 -->
        <div v-if="popularStats.popularClubs?.length > 0" class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <span class="inline-flex items-center justify-center w-6 h-6 bg-red-500 text-white text-xs font-bold rounded-full mr-2">
              🔥
            </span>
            熱門社團 (第一志願超過名額)
          </h3>
          
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <div
              v-for="club in popularStats.popularClubs"
              :key="club.id"
              class="border border-red-200 bg-red-50 rounded-lg p-4"
            >
              <div class="flex justify-between items-start mb-3">
                <div>
                  <h4 class="font-semibold text-gray-900">{{ club.name }}</h4>
                  <p class="text-sm text-gray-600">{{ club.category }} | {{ club.teacher_name }}</p>
                </div>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                  熱門
                </span>
              </div>
              
              <div class="space-y-2">
                <div class="flex justify-between text-sm">
                  <span class="text-gray-600">第一志願人數:</span>
                  <span class="font-semibold text-red-600">{{ club.first_choice_count }}</span>
                </div>
                <div class="flex justify-between text-sm">
                  <span class="text-gray-600">社團上限:</span>
                  <span class="font-semibold">{{ club.max_members }}</span>
                </div>
                <div class="flex justify-between text-sm">
                  <span class="text-gray-600">超額人數:</span>
                  <span class="font-semibold text-red-600">+{{ club.oversubscribed_by }}</span>
                </div>
              </div>
              
              <!-- 熱門程度條 -->
              <div class="mt-3">
                <div class="flex justify-between text-xs text-gray-600 mb-1">
                  <span>熱門程度</span>
                  <span>{{ Math.round((club.first_choice_count / club.max_members) * 100) }}%</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div
                    class="bg-red-500 h-2 rounded-full"
                    :style="{ width: Math.min((club.first_choice_count / club.max_members) * 100, 100) + '%' }"
                  ></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 所有社團統計 -->
        <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">所有社團選社統計</h3>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    社團名稱
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    類別
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    指導老師
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    第一志願人數
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    社團上限
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    狀態
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr
                  v-for="club in popularStats.allClubs"
                  :key="club.id"
                  :class="club.is_popular ? 'bg-red-50' : ''"
                >
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <span v-if="club.is_popular" class="text-red-500 mr-2">🔥</span>
                      <div class="text-sm font-medium text-gray-900">{{ club.name }}</div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {{ club.category }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {{ club.teacher_name }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="text-sm font-semibold" :class="club.is_popular ? 'text-red-600' : 'text-gray-900'">
                      {{ club.first_choice_count }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {{ club.max_members }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span
                      v-if="club.is_popular"
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
                    >
                      熱門 (+{{ club.oversubscribed_by }})
                    </span>
                    <span
                      v-else-if="club.first_choice_count === 0"
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                    >
                      待選
                    </span>
                    <span
                      v-else
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                    >
                      正常
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'
import { useRoute } from 'vue-router'
import dayjs from 'dayjs'
import axios from 'axios'

// 註冊 Chart.js 組件
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

const route = useRoute()
const schoolId = route.params.schoolId as string

// Tab 狀態
const activeTab = ref('daily')

// 每日統計數據狀態
const loading = ref(true)
const error = ref('')
const dailyStats = ref<any[]>([])
const statistics = ref({
  totalRegistrations: 0,
  todayRegistrations: 0,
  completionRate: 0,
  averageDaily: 0
})

// 熱門社團數據狀態
const popularLoading = ref(false)
const popularError = ref('')
const popularStats = ref<{
  popularClubs: any[]
  allClubs: any[]
  totalPopularClubs: number
}>({
  popularClubs: [],
  allClubs: [],
  totalPopularClubs: 0
})

// 最熱門社團（第一志願最多的）
const topClub = computed(() => {
  if (popularStats.value.popularClubs.length === 0) return null
  return popularStats.value.popularClubs[0]
})

// 圖表配置
const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    },
    title: {
      display: false
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      ticks: {
        stepSize: 1
      }
    }
  }
}

// 圖表數據
const chartData = computed(() => ({
  labels: dailyStats.value.map(item => formatDate(item.date)),
  datasets: [
    {
      label: '每日選社人數',
      data: dailyStats.value.map(item => item.count),
      backgroundColor: 'rgba(59, 130, 246, 0.5)',
      borderColor: 'rgba(59, 130, 246, 1)',
      borderWidth: 1,
      borderRadius: 4,
      borderSkipped: false,
    }
  ]
}))

// 格式化日期
const formatDate = (date: string) => {
  return dayjs(date).format('MM/DD')
}

// 載入數據
const loadData = async () => {
  try {
    loading.value = true
    error.value = ''
    
    // 調用 API 獲取每日選社統計數據
    const response = await axios.get(`/api/schools/${schoolId}/statistics/daily`)
    
    const data = response.data
    dailyStats.value = data.dailyStats || []
    statistics.value = {
      totalRegistrations: data.totalRegistrations || 0,
      todayRegistrations: data.todayRegistrations || 0,
      completionRate: data.completionRate || 0,
      averageDaily: data.averageDaily || 0
    }
    
  } catch (err: any) {
    error.value = err.response?.data?.message || '載入數據失敗'
    
    // 如果 API 不存在，使用模擬數據
    if (err.response?.status === 404) {
      loadMockData()
    }
  } finally {
    loading.value = false
  }
}

// 載入模擬數據（用於開發階段）
const loadMockData = () => {
  const mockData = []
  let cumulative = 0
  
  // 生成 7 天的模擬數據
  for (let i = 6; i >= 0; i--) {
    const date = dayjs().subtract(i, 'day')
    const count = Math.floor(Math.random() * 50) + 10
    cumulative += count
    
    mockData.push({
      date: date.format('YYYY-MM-DD'),
      count: count,
      cumulative: cumulative,
      completionRate: Math.min((cumulative / 200) * 100, 100)
    })
  }
  
  dailyStats.value = mockData
  statistics.value = {
    totalRegistrations: cumulative,
    todayRegistrations: mockData[mockData.length - 1]?.count || 0,
    completionRate: Math.min((cumulative / 200) * 100, 100),
    averageDaily: Math.round(cumulative / 7)
  }
}

// 載入熱門社團數據
const loadPopularData = async () => {
  try {
    popularLoading.value = true
    popularError.value = ''
    
    // 調用熱門社團 API
    const response = await axios.get(`/api/public/schools/${schoolId}/clubs/popular`)
    const data = response.data
    
    popularStats.value = {
      popularClubs: data.popular_clubs || [],
      allClubs: data.all_clubs || [],
      totalPopularClubs: data.total_popular_clubs || 0
    }
    
  } catch (err: any) {
    popularError.value = err.response?.data?.message || '載入熱門社團數據失敗'
    console.error('載入熱門社團數據失敗:', err)
  } finally {
    popularLoading.value = false
  }
}

// 監聽 tab 切換，切換到熱門社團時載入數據
const handleTabChange = () => {
  if (activeTab.value === 'popular' && popularStats.value.allClubs.length === 0) {
    loadPopularData()
  }
}

// 使用 watch 來監聽 activeTab 變化
watch(activeTab, handleTabChange)

// 組件掛載時載入數據
onMounted(() => {
  loadData()
})
</script>
