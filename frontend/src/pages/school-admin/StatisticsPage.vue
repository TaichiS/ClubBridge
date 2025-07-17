<template>
  <div class="p-8">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">選社即時統計</h1>
      <p class="text-gray-600">查看選社期間的每日報名統計數據</p>
    </div>

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
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'
import { useRoute } from 'vue-router'
import dayjs from 'dayjs'
import axios from 'axios'

// 註冊 Chart.js 組件
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

const route = useRoute()
const schoolId = route.params.schoolId as string

// 數據狀態
const loading = ref(true)
const error = ref('')
const dailyStats = ref<any[]>([])
const statistics = ref({
  totalRegistrations: 0,
  todayRegistrations: 0,
  completionRate: 0,
  averageDaily: 0
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

// 組件掛載時載入數據
onMounted(() => {
  loadData()
})
</script>
