<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
    <!-- 頂部導航 -->
    <nav class="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <!-- 學校 Logo 和名稱 -->
          <div class="flex items-center space-x-4">
            <div class="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
              <span class="text-white font-bold text-lg">🏫</span>
            </div>
            <div>
              <h1 class="text-xl font-bold text-gray-900">{{ schoolInfo?.name || '載入中...' }}</h1>
              <p class="text-xs text-gray-500">學生選社系統</p>
            </div>
          </div>

          <!-- 導航按鈕 -->
          <div class="flex items-center space-x-4">
            <button
              @click="navigateToClubs"
              class="px-4 py-2 text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors duration-200"
            >
              瀏覽社團
            </button>
            <button
              @click="navigateToSelection"
              class="px-6 py-2 bg-gradient-to-r from-green-500 to-blue-600 text-white rounded-lg hover:from-green-600 hover:to-blue-700 transition-all duration-200 shadow-md hover:shadow-lg transform hover:scale-105 mr-2"
            >
              開始選社
            </button>
            <button
              @click="navigateToLogin"
              class="px-6 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 transition-all duration-200 shadow-md hover:shadow-lg transform hover:scale-105"
            >
              學生登入
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- 主要內容 -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- 載入狀態 -->
      <div v-if="isLoading" class="text-center py-20">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p class="text-gray-600">載入學校資訊中...</p>
      </div>
      
      <!-- 錯誤狀態 -->
      <div v-else-if="error" class="text-center py-20">
        <div class="text-red-500 text-6xl mb-4">⚠️</div>
        <h2 class="text-2xl font-bold text-gray-900 mb-4">載入失敗</h2>
        <p class="text-gray-600 mb-6">{{ error }}</p>
        <button 
          @click="window.location.reload()" 
          class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          重新載入
        </button>
      </div>
      
      <!-- 正常內容 -->
      <template v-else-if="schoolInfo">
      <!-- 英雄區域 -->
      <section class="text-center mb-16">
        <div class="animate-fade-in">
          <h2 class="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
            歡迎來到 
            <span class="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              {{ schoolInfo?.name || '載入中...' }}
            </span>
          </h2>
          <p class="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            {{ schoolInfo?.description || '載入學校資訊中...' }}
          </p>
          
          <!-- 選社時程卡片 -->
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg p-8 mb-8 border border-gray-200">
            <div class="flex items-center justify-center mb-6">
              <div class="w-16 h-16 bg-gradient-to-r from-green-400 to-blue-500 rounded-full flex items-center justify-center">
                <span class="text-white text-2xl">⏰</span>
              </div>
            </div>
            
            <h3 class="text-2xl font-bold text-gray-900 mb-4">選社時程</h3>
            
            <!-- 時程進度條 -->
            <div class="relative">
              <div class="flex justify-between text-sm text-gray-600 mb-2">
                <span>選社開始</span>
                <span>選社結束</span>
                <span>結果公布</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-2 mb-4">
                <div 
                  class="bg-gradient-to-r from-green-400 to-blue-500 h-2 rounded-full transition-all duration-1000 ease-out"
                  :style="{ width: progressWidth }"
                ></div>
              </div>
            </div>
            
            <!-- 時程詳情 -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 text-center">
              <div class="p-4 bg-gradient-to-r from-green-50 to-blue-50 rounded-lg">
                <div class="text-sm text-gray-600 mb-1">選社開始</div>
                <div class="font-semibold text-gray-900">{{ formatDate(schedule.registrationStart) }}</div>
              </div>
              <div class="p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg">
                <div class="text-sm text-gray-600 mb-1">選社結束</div>
                <div class="font-semibold text-gray-900">{{ formatDate(schedule.registrationEnd) }}</div>
              </div>
              <div class="p-4 bg-gradient-to-r from-purple-50 to-pink-50 rounded-lg">
                <div class="text-sm text-gray-600 mb-1">結果公布</div>
                <div class="font-semibold text-gray-900">{{ formatDate(schedule.resultAnnouncement) }}</div>
              </div>
            </div>
            
            <!-- 狀態指示器 -->
            <div class="mt-6 flex justify-center">
              <div :class="[
                'px-4 py-2 rounded-full text-sm font-medium',
                schedule?.isRegistrationOpen 
                  ? 'bg-green-100 text-green-800' 
                  : 'bg-gray-100 text-gray-600'
              ]">
                {{ schedule?.isRegistrationOpen ? '🟢 選社進行中' : '⏳ 尚未開始' }}
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 統計數據 -->
      <section class="mb-16">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div 
            v-for="(stat, index) in stats" 
            :key="index"
            class="bg-white/80 backdrop-blur-sm rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-gray-200 hover:border-blue-300 transform hover:-translate-y-1"
            :class="`animate-slide-in-${index + 1}`"
          >
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-gray-600">{{ stat.label }}</p>
                <p class="text-2xl font-bold text-gray-900">{{ stat.value }}</p>
              </div>
              <div :class="[
                'w-12 h-12 rounded-lg flex items-center justify-center text-white text-xl',
                stat.color
              ]">
                {{ stat.icon }}
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 社團分類 -->
      <section class="mb-16">
        <h3 class="text-3xl font-bold text-gray-900 text-center mb-8">社團分類</h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
          <div 
            v-for="(category, index) in categories" 
            :key="index"
            class="group bg-white/80 backdrop-blur-sm rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-gray-200 hover:border-blue-300 cursor-pointer transform hover:-translate-y-2"
            @click="navigateToClubsByCategory(category.name)"
          >
            <div class="text-center">
              <div :class="[
                'w-16 h-16 mx-auto mb-4 rounded-full flex items-center justify-center text-white text-2xl group-hover:scale-110 transition-transform duration-300',
                category.color
              ]">
                {{ category.icon }}
              </div>
              <h4 class="font-semibold text-gray-900 mb-2">{{ category.name }}</h4>
              <p class="text-sm text-gray-600">{{ category.count }} 個社團</p>
            </div>
          </div>
        </div>
      </section>

      <!-- 重要公告 -->
      <section class="mb-16">
        <h3 class="text-3xl font-bold text-gray-900 text-center mb-8">重要公告</h3>
        <div class="max-w-4xl mx-auto">
          <div 
            v-for="announcement in announcements" 
            :key="announcement.id"
            :class="[
              'bg-white/80 backdrop-blur-sm rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border-l-4 mb-6',
              announcement.priority === 'high' ? 'border-red-500 bg-red-50/50' : 
              announcement.priority === 'medium' ? 'border-yellow-500 bg-yellow-50/50' : 
              'border-blue-500 bg-blue-50/50'
            ]"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center mb-2">
                  <span :class="[
                    'inline-block w-2 h-2 rounded-full mr-3',
                    announcement.priority === 'high' ? 'bg-red-500' : 
                    announcement.priority === 'medium' ? 'bg-yellow-500' : 
                    'bg-blue-500'
                  ]"></span>
                  <h4 class="font-semibold text-gray-900">{{ announcement.title }}</h4>
                  <span v-if="announcement.isSticky" class="ml-2 text-xs bg-orange-100 text-orange-800 px-2 py-1 rounded-full">
                    置頂
                  </span>
                </div>
                <div class="text-gray-600 mb-2 prose prose-sm max-w-none" v-html="renderMarkdown(announcement.content)"></div>
                <p class="text-sm text-gray-500">{{ formatDate(announcement.createdAt) }}</p>
              </div>
            </div>
          </div>
        </div>
      </section>
      </template>
    </main>

    <!-- 底部 -->
    <footer class="bg-gray-50 border-t border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="text-center text-gray-600">
          <p>&copy; 2024 {{ schoolInfo?.name || '學校' }} 學生選社系統</p>
          <p class="text-sm mt-2">Powered by ClubBridge</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { schoolApi } from '@/api/school'
import { useMarkdown } from '@/composables/useMarkdown'
import type { School } from '@/types/school'

const route = useRoute()
const { renderMarkdown } = useMarkdown()

// 真實資料
const schoolInfo = ref<School | null>(null)
const isLoading = ref(true)
const error = ref<string | null>(null)

// 從路由取得學校ID
const schoolId = computed(() => {
  return Number(route.params.schoolId)
})

const schedule = computed(() => {
  if (!schoolInfo.value) return null
  
  const now = new Date()
  const startTime = schoolInfo.value.club_selection_start_time ? new Date(schoolInfo.value.club_selection_start_time) : null
  const endTime = schoolInfo.value.club_selection_end_time ? new Date(schoolInfo.value.club_selection_end_time) : null
  const resultStartTime = schoolInfo.value.result_announcement_start_time ? new Date(schoolInfo.value.result_announcement_start_time) : null
  const resultEndTime = schoolInfo.value.result_announcement_end_time ? new Date(schoolInfo.value.result_announcement_end_time) : null
  
  return {
    registrationStart: startTime,
    registrationEnd: endTime,
    resultAnnouncement: resultStartTime,
    resultAnnouncementEnd: resultEndTime,
    isRegistrationOpen: startTime && endTime && now >= startTime && now <= endTime
  }
})

const stats = computed(() => [
  {
    label: '社團總數',
    value: schoolInfo.value?.club_count || '0',
    icon: '🎭',
    color: 'bg-gradient-to-r from-blue-500 to-purple-600'
  },
  {
    label: '學生總數',
    value: schoolInfo.value?.student_count || '0',
    icon: '👥',
    color: 'bg-gradient-to-r from-green-500 to-blue-500'
  },
  {
    label: '最少志願數',
    value: schoolInfo.value?.min_required_choices || '3',
    icon: '📝',
    color: 'bg-gradient-to-r from-purple-500 to-pink-500'
  },
  {
    label: '學校類型',
    value: getSchoolTypeText(schoolInfo.value?.school_type),
    icon: '🏫',
    color: 'bg-gradient-to-r from-orange-500 to-red-500'
  }
])

const categories = ref<any[]>([])

const announcements = computed(() => {
  if (!schoolInfo.value) return []
  
  const items = []
  
  // 置頂公告
  if (schoolInfo.value.top_announcement) {
    items.push({
      id: 'top',
      title: '置頂公告',
      content: schoolInfo.value.top_announcement,
      createdAt: new Date(),
      priority: 'high' as const,
      isSticky: true
    })
  }
  
  // 一般公告
  if (schoolInfo.value.announcement) {
    items.push({
      id: 'general',
      title: '一般公告',
      content: schoolInfo.value.announcement,
      createdAt: new Date(),
      priority: 'medium' as const,
      isSticky: false
    })
  }
  
  // 學期課程資訊
  if (schoolInfo.value.semester_schedule) {
    items.push({
      id: 'schedule',
      title: '本學期上課時間',
      content: schoolInfo.value.semester_schedule,
      createdAt: new Date(),
      priority: 'medium' as const,
      isSticky: false
    })
  }
  
  return items
})

const progressWidth = computed(() => {
  if (!schedule.value?.registrationStart || !schedule.value?.resultAnnouncement) return '0%'
  
  const now = new Date()
  const start = schedule.value.registrationStart
  const end = schedule.value.resultAnnouncement
  
  if (now < start) return '0%'
  if (now > end) return '100%'
  
  const progress = ((now.getTime() - start.getTime()) / (end.getTime() - start.getTime())) * 100
  return `${Math.min(progress, 100)}%`
})

const formatDate = (date: Date | null) => {
  if (!date) return '未設定'
  return date.toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getSchoolTypeText = (type: string | undefined) => {
  switch (type) {
    case 'elementary': return '國小'
    case 'junior_high': return '國中'
    case 'senior_high': return '高中'
    case 'vocational': return '高職'
    case 'university': return '大學'
    default: return '學校'
  }
}

const navigateToClubs = () => {
  window.location.href = `/schools/${schoolId.value}/student/clubs`
}

const navigateToLogin = () => {
  window.location.href = `/schools/${schoolId.value}/student/login`
}

const navigateToSelection = () => {
  window.location.href = `/schools/${schoolId.value}/student/selection`
}

const navigateToClubsByCategory = (category: string) => {
  window.location.href = `/schools/${schoolId.value}/student/clubs?category=${encodeURIComponent(category)}`
}

onMounted(async () => {
  // 載入學校資料
  try {
    // 同時載入學校資料和社團類別
    const [schoolData, categoryData] = await Promise.all([
      schoolApi.getPublicSchool(schoolId.value),
      schoolApi.getClubCategories(schoolId.value)
    ])
    
    schoolInfo.value = schoolData
    categories.value = categoryData
  } catch (err) {
    console.error('載入學校資料失敗:', err)
    error.value = '載入學校資料失敗'
  } finally {
    isLoading.value = false
  }
  
  // 添加動畫效果
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  }
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-fade-in')
      }
    })
  }, observerOptions)
  
  document.querySelectorAll('section').forEach(section => {
    observer.observe(section)
  })
})
</script>

<style scoped>
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slide-in-1 {
  from {
    opacity: 0;
    transform: translateX(-50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slide-in-2 {
  from {
    opacity: 0;
    transform: translateX(-50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slide-in-3 {
  from {
    opacity: 0;
    transform: translateX(-50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slide-in-4 {
  from {
    opacity: 0;
    transform: translateX(-50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.8s ease-out;
}

.animate-slide-in-1 {
  animation: slide-in-1 0.6s ease-out 0.1s both;
}

.animate-slide-in-2 {
  animation: slide-in-2 0.6s ease-out 0.2s both;
}

.animate-slide-in-3 {
  animation: slide-in-3 0.6s ease-out 0.3s both;
}

.animate-slide-in-4 {
  animation: slide-in-4 0.6s ease-out 0.4s both;
}
</style>