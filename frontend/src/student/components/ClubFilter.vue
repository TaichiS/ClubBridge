<template>
  <div class="club-filter bg-white/80 backdrop-blur-sm rounded-xl shadow-lg border border-gray-200">
    <!-- 篩選標題 -->
    <div class="p-6 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold text-gray-900">篩選社團</h3>
        <button
          @click="resetFilters"
          class="text-sm text-blue-600 hover:text-blue-800 transition-colors duration-200"
        >
          重置篩選
        </button>
      </div>
    </div>

    <div class="p-6 space-y-6">
      <!-- 搜尋框 -->
      <div class="relative">
        <input
          v-model="localFilters.searchTerm"
          type="text"
          placeholder="搜尋社團名稱、老師或關鍵字..."
          class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
          @input="debounceSearch"
        >
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
        
        <!-- 搜尋建議 -->
        <div
          v-if="searchSuggestions.length > 0 && localFilters.searchTerm.length > 0"
          class="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto"
        >
          <div
            v-for="suggestion in searchSuggestions"
            :key="suggestion.id"
            class="p-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0"
            @click="selectSearchSuggestion(suggestion)"
          >
            <div class="flex items-center space-x-3">
              <span class="text-2xl">{{ getCategoryIcon(suggestion.category) }}</span>
              <div>
                <p class="font-medium text-gray-900">{{ suggestion.name }}</p>
                <p class="text-sm text-gray-600">{{ suggestion.category }} • {{ suggestion.teacher }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 快速篩選標籤 -->
      <div class="flex flex-wrap gap-2">
        <button
          v-for="tag in quickFilters"
          :key="tag.key"
          @click="toggleQuickFilter(tag.key)"
          :class="[
            'px-3 py-1.5 rounded-full text-sm font-medium transition-all duration-200',
            tag.active
              ? 'bg-blue-500 text-white shadow-md'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          ]"
        >
          {{ tag.icon }} {{ tag.label }}
        </button>
      </div>

      <!-- 社團分類 -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-900">社團分類</h4>
        <div class="grid grid-cols-2 gap-2">
          <label
            v-for="category in categories"
            :key="category.name"
            class="flex items-center space-x-2 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 cursor-pointer transition-all duration-200"
            :class="localFilters.categories.includes(category.name) ? 'bg-blue-50 border-blue-300' : ''"
          >
            <input
              v-model="localFilters.categories"
              type="checkbox"
              :value="category.name"
              class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
            >
            <span class="text-lg">{{ category.icon }}</span>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">{{ category.name }}</p>
              <p class="text-xs text-gray-500">{{ category.count }} 個社團</p>
            </div>
          </label>
        </div>
      </div>

      <!-- 年級限制 -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-900">年級限制</h4>
        <div class="grid grid-cols-3 gap-2">
          <label
            v-for="grade in grades"
            :key="grade"
            class="flex items-center justify-center space-x-2 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 cursor-pointer transition-all duration-200"
            :class="localFilters.grades.includes(grade) ? 'bg-blue-50 border-blue-300' : ''"
          >
            <input
              v-model="localFilters.grades"
              type="checkbox"
              :value="grade"
              class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
            >
            <span class="text-sm font-medium text-gray-900">{{ grade }}</span>
          </label>
        </div>
      </div>

      <!-- 名額狀態 -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-900">名額狀態</h4>
        <div class="space-y-2">
          <label class="flex items-center space-x-2 cursor-pointer">
            <input
              v-model="localFilters.hasAvailableSpots"
              type="checkbox"
              class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"
            >
            <span class="text-sm text-gray-900">僅顯示有名額的社團</span>
          </label>
        </div>
      </div>

      <!-- 費用範圍 -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-900">費用範圍</h4>
        <div class="space-y-4">
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600 w-16">免費</span>
            <input
              v-model="localFilters.maxCost"
              type="range"
              min="0"
              max="5000"
              step="100"
              class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
            >
            <span class="text-sm text-gray-600 w-16">{{ localFilters.maxCost }}元</span>
          </div>
          <div class="flex justify-between text-xs text-gray-500">
            <span>0元</span>
            <span>2500元</span>
            <span>5000元</span>
          </div>
        </div>
      </div>

      <!-- 排序選項 -->
      <div class="space-y-3">
        <h4 class="font-medium text-gray-900">排序方式</h4>
        <div class="grid grid-cols-2 gap-2">
          <label
            v-for="sort in sortOptions"
            :key="sort.value"
            class="flex items-center space-x-2 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 cursor-pointer transition-all duration-200"
            :class="localFilters.sortBy === sort.value ? 'bg-blue-50 border-blue-300' : ''"
          >
            <input
              v-model="localFilters.sortBy"
              type="radio"
              :value="sort.value"
              class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500 focus:ring-2"
            >
            <span class="text-sm font-medium text-gray-900">{{ sort.label }}</span>
          </label>
        </div>
        
        <!-- 排序方向 -->
        <div class="flex items-center space-x-4">
          <span class="text-sm text-gray-600">排序方向:</span>
          <label class="flex items-center space-x-2 cursor-pointer">
            <input
              v-model="localFilters.sortOrder"
              type="radio"
              value="asc"
              class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500 focus:ring-2"
            >
            <span class="text-sm text-gray-900">升序</span>
          </label>
          <label class="flex items-center space-x-2 cursor-pointer">
            <input
              v-model="localFilters.sortOrder"
              type="radio"
              value="desc"
              class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500 focus:ring-2"
            >
            <span class="text-sm text-gray-900">降序</span>
          </label>
        </div>
      </div>

      <!-- 篩選結果統計 -->
      <div class="pt-4 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-600">
            找到 <span class="font-semibold text-gray-900">{{ filteredCount }}</span> 個社團
          </div>
          <div class="flex items-center space-x-2">
            <div class="w-2 h-2 bg-green-500 rounded-full"></div>
            <span class="text-xs text-gray-500">{{ availableCount }} 個有名額</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import type { ClubFilter } from '@/student/types/club'

interface Category {
  name: string
  icon: string
  count: number
}

interface SearchSuggestion {
  id: string
  name: string
  category: string
  teacher: string
}

interface QuickFilter {
  key: string
  label: string
  icon: string
  active: boolean
}

interface Props {
  filters: ClubFilter
  categories: Category[]
  filteredCount: number
  availableCount: number
  searchSuggestions?: SearchSuggestion[]
}

interface Emits {
  (e: 'update:filters', filters: ClubFilter): void
  (e: 'search-suggestion-selected', suggestion: SearchSuggestion): void
}

const props = withDefaults(defineProps<Props>(), {
  searchSuggestions: () => []
})

const emit = defineEmits<Emits>()

// 本地篩選器狀態
const localFilters = reactive<ClubFilter>({ ...props.filters })

// 年級選項
const grades = ref(['國一', '國二', '國三', '高一', '高二', '高三'])

// 排序選項
const sortOptions = ref([
  { value: 'name', label: '社團名稱' },
  { value: 'popularity', label: '熱門程度' },
  { value: 'available', label: '剩餘名額' },
  { value: 'rating', label: '評分' }
])

// 快速篩選標籤
const quickFilters = ref<QuickFilter[]>([
  { key: 'popular', label: '熱門社團', icon: '🔥', active: false },
  { key: 'available', label: '有名額', icon: '✅', active: false },
  { key: 'newbie', label: '新手友善', icon: '👋', active: false },
  { key: 'free', label: '免費', icon: '💰', active: false }
])

// 搜尋防抖
let searchTimeout: NodeJS.Timeout | null = null

const debounceSearch = () => {
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }
  searchTimeout = setTimeout(() => {
    emitFilters()
  }, 300)
}

// 選擇搜尋建議
const selectSearchSuggestion = (suggestion: SearchSuggestion) => {
  localFilters.searchTerm = suggestion.name
  emit('search-suggestion-selected', suggestion)
  emitFilters()
}

// 切換快速篩選
const toggleQuickFilter = (key: string) => {
  const filter = quickFilters.value.find(f => f.key === key)
  if (filter) {
    filter.active = !filter.active
    
    // 根據快速篩選更新主要篩選器
    switch (key) {
      case 'available':
        localFilters.hasAvailableSpots = filter.active
        break
      case 'free':
        if (filter.active) {
          localFilters.maxCost = 0
        }
        break
      // 其他快速篩選邏輯
    }
    
    emitFilters()
  }
}

// 重置篩選器
const resetFilters = () => {
  localFilters.categories = []
  localFilters.grades = []
  localFilters.hasAvailableSpots = false
  localFilters.maxCost = 5000
  localFilters.searchTerm = ''
  localFilters.sortBy = 'name'
  localFilters.sortOrder = 'asc'
  
  quickFilters.value.forEach(filter => {
    filter.active = false
  })
  
  emitFilters()
}

// 發送篩選器更新
const emitFilters = () => {
  emit('update:filters', { ...localFilters })
}

// 獲取分類圖標
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

// 監聽篩選器變化
watch(localFilters, () => {
  emitFilters()
}, { deep: true })

// 監聽外部篩選器更新
watch(() => props.filters, (newFilters) => {
  Object.assign(localFilters, newFilters)
}, { deep: true })
</script>

<style scoped>
/* 自訂滑塊樣式 */
input[type="range"] {
  background: linear-gradient(to right, #3B82F6 0%, #8B5CF6 100%);
}

input[type="range"]::-webkit-slider-thumb {
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #3B82F6;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

input[type="range"]::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #3B82F6;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

/* 複選框和單選框樣式 */
input[type="checkbox"]:checked,
input[type="radio"]:checked {
  background-color: #3B82F6;
  border-color: #3B82F6;
}

/* 動畫效果 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .grid-cols-2 {
    @apply grid-cols-1;
  }
  
  .grid-cols-3 {
    @apply grid-cols-2;
  }
}
</style>