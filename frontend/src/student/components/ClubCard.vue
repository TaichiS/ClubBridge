<template>
  <div
    class="group relative bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 border border-gray-200 hover:border-blue-300 overflow-hidden transform hover:-translate-y-2"
    :class="{ 'opacity-75': !club.availableSpots }"
  >
    <!-- 社團圖片 -->
    <div class="relative h-48 bg-gradient-to-br from-blue-100 to-purple-100 overflow-hidden">
      <img
        v-if="club.image"
        :src="club.image"
        :alt="club.name"
        class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        @error="handleImageError"
      >
      <div
        v-else
        class="w-full h-full flex items-center justify-center text-4xl text-gray-400"
      >
        {{ getCategoryIcon(club.category) }}
      </div>
      
      <!-- 熱門標籤 -->
      <div
        v-if="club.isPopular"
        class="absolute top-3 left-3 bg-gradient-to-r from-orange-400 to-red-500 text-white px-2 py-1 rounded-full text-xs font-bold flex items-center space-x-1"
      >
        <span>🔥</span>
        <span>熱門</span>
      </div>
      
      <!-- 名額狀態 -->
      <div
        class="absolute top-3 right-3 px-2 py-1 rounded-full text-xs font-bold"
        :class="club.availableSpots > 0 
          ? 'bg-green-500 text-white' 
          : 'bg-red-500 text-white'"
      >
        {{ club.availableSpots > 0 ? `${club.availableSpots} 名額` : '已滿' }}
      </div>
      
      <!-- 評分 -->
      <div
        v-if="club.rating"
        class="absolute bottom-3 left-3 bg-black/50 text-white px-2 py-1 rounded-full text-xs flex items-center space-x-1"
      >
        <span>⭐</span>
        <span>{{ club.rating }}</span>
      </div>
    </div>
    
    <!-- 社團資訊 -->
    <div class="p-6">
      <div class="flex items-start justify-between mb-3">
        <div class="flex-1">
          <h3 class="text-lg font-bold text-gray-900 group-hover:text-blue-600 transition-colors duration-200 mb-1">
            {{ club.name }}
          </h3>
          <p class="text-sm text-gray-600 flex items-center">
            <span class="mr-1">👨‍🏫</span>
            {{ club.teacher }}
          </p>
        </div>
        
        <div class="flex flex-col items-end space-y-2">
          <span
            class="px-3 py-1 rounded-full text-xs font-medium"
            :class="club.categoryColor"
          >
            {{ club.category }}
          </span>
        </div>
      </div>
      
      <!-- 地點資訊 -->
      <div class="flex items-center text-sm text-gray-600 mb-3">
        <span class="mr-1">📍</span>
        <span>{{ club.location }}</span>
      </div>
      
      <!-- 人數統計 -->
      <div class="mb-4">
        <div class="flex items-center justify-between text-sm text-gray-600 mb-1">
          <span>報名人數</span>
          <span>{{ club.currentCount }} / {{ club.maxCapacity }}</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-2">
          <div
            class="bg-gradient-to-r from-blue-500 to-purple-600 h-2 rounded-full transition-all duration-500"
            :style="{ width: `${(club.currentCount / club.maxCapacity) * 100}%` }"
          ></div>
        </div>
      </div>
      
      <!-- 標籤 -->
      <div class="flex flex-wrap gap-1 mb-4">
        <span
          v-for="tag in club.tags"
          :key="tag"
          class="px-2 py-1 bg-gray-100 text-gray-700 rounded-full text-xs"
        >
          {{ tag }}
        </span>
      </div>
      
      <!-- 動作按鈕 -->
      <div class="flex space-x-2">
        <button
          @click="$emit('view-details', club)"
          class="flex-1 py-2 px-4 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors duration-200 text-sm font-medium"
        >
          查看詳情
        </button>
        <button
          @click="$emit('add-to-selection', club)"
          :disabled="!club.availableSpots"
          class="flex-1 py-2 px-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 text-sm font-medium"
        >
          {{ club.availableSpots ? '選擇' : '已滿' }}
        </button>
      </div>
    </div>
    
    <!-- 拖拽指示器 -->
    <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none">
      <div class="bg-white/90 rounded-full p-2">
        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"></path>
        </svg>
      </div>
    </div>
    
    <!-- 載入中遮罩 -->
    <div
      v-if="isLoading"
      class="absolute inset-0 bg-white/80 flex items-center justify-center"
    >
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import type { ClubCard } from '@/student/types/club'

interface Props {
  club: ClubCard
  isLoading?: boolean
}

interface Emits {
  (e: 'view-details', club: ClubCard): void
  (e: 'add-to-selection', club: ClubCard): void
}

const props = withDefaults(defineProps<Props>(), {
  isLoading: false
})

const emit = defineEmits<Emits>()

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement
  target.style.display = 'none'
}

const getCategoryIcon = (category: string): string => {
  const icons: Record<string, string> = {
    '體育類': '⚽',
    '藝文類': '🎨',
    '學術類': '🔬',
    '服務類': '🤝',
    '技能類': '💻',
    '音樂類': '🎵',
    '語言類': '🗣️',
    '其他': '🌟'
  }
  return icons[category] || '🎭'
}
</script>

<style scoped>
/* 動畫效果 */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .group {
    @apply hover:transform-none;
  }
  
  .group:hover {
    @apply translate-y-0;
  }
}
</style>