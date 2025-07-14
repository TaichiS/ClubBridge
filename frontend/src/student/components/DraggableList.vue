<template>
  <div
    class="draggable-list"
    @touchstart="handleTouchStart"
    @touchmove="handleTouchMove"
    @touchend="handleTouchEnd"
  >
    <div
      v-for="(item, index) in items"
      :key="item.id"
      class="draggable-item"
      :class="[
        'transition-all duration-300 ease-out',
        {
          'is-dragging': dragState.draggedIndex === index,
          'is-drag-over': dragState.dragOverIndex === index,
          'is-animating': animatingItems.has(index)
        }
      ]"
      :style="getItemStyle(index)"
      :data-index="index"
      draggable="true"
      @dragstart="handleDragStart($event, index)"
      @dragend="handleDragEnd"
      @dragover.prevent="handleDragOver($event, index)"
      @drop.prevent="handleDrop($event, index)"
    >
      <div class="item-content">
        <!-- 志願序號 -->
        <div class="absolute -left-3 -top-3 z-10">
          <div class="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-full flex items-center justify-center text-sm font-bold shadow-lg">
            {{ index + 1 }}
          </div>
        </div>

        <!-- 拖拽手柄 -->
        <div class="drag-handle absolute right-3 top-3 cursor-move touch-none">
          <div class="flex flex-col space-y-1 p-2 rounded-lg bg-gray-100 hover:bg-gray-200 transition-colors">
            <div class="w-4 h-0.5 bg-gray-400 rounded"></div>
            <div class="w-4 h-0.5 bg-gray-400 rounded"></div>
            <div class="w-4 h-0.5 bg-gray-400 rounded"></div>
          </div>
        </div>

        <!-- 主要內容 -->
        <div class="pr-16 pl-4">
          <slot :item="item" :index="index" :isDragging="dragState.draggedIndex === index"></slot>
        </div>

        <!-- 刪除按鈕 -->
        <button
          @click="removeItem(index)"
          class="absolute right-16 top-1/2 transform -translate-y-1/2 w-8 h-8 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors duration-200 flex items-center justify-center opacity-0 group-hover:opacity-100"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>

      <!-- 插入指示器 -->
      <div
        v-if="dragState.dragOverIndex === index && dragState.draggedIndex !== index"
        class="insert-indicator absolute inset-x-0 top-0 h-1 bg-blue-500 rounded-full -translate-y-1 opacity-80"
      ></div>
    </div>

    <!-- 空狀態 -->
    <div
      v-if="items.length === 0"
      class="empty-state text-center py-16 text-gray-500"
    >
      <div class="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
        <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
      </div>
      <p class="text-lg font-medium mb-2">{{ emptyStateTitle }}</p>
      <p class="text-sm">{{ emptyStateMessage }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, nextTick } from 'vue'

interface DraggableItem {
  id: string
  [key: string]: any
}

interface Props {
  items: DraggableItem[]
  emptyStateTitle?: string
  emptyStateMessage?: string
  maxItems?: number
  allowReorder?: boolean
  animationDuration?: number
}

interface Emits {
  (e: 'update:items', items: DraggableItem[]): void
  (e: 'item-removed', item: DraggableItem, index: number): void
  (e: 'item-reordered', from: number, to: number): void
}

const props = withDefaults(defineProps<Props>(), {
  emptyStateTitle: '尚未選擇任何項目',
  emptyStateMessage: '拖拽項目到此處或點擊添加',
  maxItems: 5,
  allowReorder: true,
  animationDuration: 300
})

const emit = defineEmits<Emits>()

// 拖拽狀態
const dragState = reactive({
  isDragging: false,
  draggedIndex: -1,
  dragOverIndex: -1,
  draggedItem: null as DraggableItem | null,
  startY: 0,
  currentY: 0,
  initialScrollTop: 0
})

// 觸控狀態
const touchState = reactive({
  startY: 0,
  startX: 0,
  currentY: 0,
  currentX: 0,
  isTouching: false,
  touchStartTime: 0,
  longPressTimer: null as NodeJS.Timeout | null,
  isLongPress: false
})

// 動畫狀態
const animatingItems = ref(new Set<number>())

// 桌面拖拽處理
const handleDragStart = (event: DragEvent, index: number) => {
  if (!props.allowReorder) return
  
  dragState.isDragging = true
  dragState.draggedIndex = index
  dragState.draggedItem = props.items[index]
  
  event.dataTransfer?.setData('text/plain', index.toString())
  event.dataTransfer!.effectAllowed = 'move'
  
  // 設置拖拽圖片
  const dragImage = event.target as HTMLElement
  event.dataTransfer?.setDragImage(dragImage, 0, 0)
}

const handleDragEnd = () => {
  dragState.isDragging = false
  dragState.draggedIndex = -1
  dragState.dragOverIndex = -1
  dragState.draggedItem = null
}

const handleDragOver = (event: DragEvent, index: number) => {
  if (!props.allowReorder) return
  
  event.preventDefault()
  dragState.dragOverIndex = index
}

const handleDrop = (event: DragEvent, dropIndex: number) => {
  if (!props.allowReorder) return
  
  event.preventDefault()
  const draggedIndex = parseInt(event.dataTransfer?.getData('text/plain') || '-1')
  
  if (draggedIndex !== -1 && draggedIndex !== dropIndex) {
    reorderItems(draggedIndex, dropIndex)
  }
  
  handleDragEnd()
}

// 觸控拖拽處理
const handleTouchStart = (event: TouchEvent) => {
  const touch = event.touches[0]
  const target = event.target as HTMLElement
  
  // 檢查是否點擊了拖拽手柄
  const dragHandle = target.closest('.drag-handle')
  if (!dragHandle) return
  
  const itemElement = target.closest('.draggable-item')
  if (!itemElement) return
  
  const index = parseInt(itemElement.getAttribute('data-index') || '-1')
  if (index === -1) return
  
  touchState.startY = touch.clientY
  touchState.startX = touch.clientX
  touchState.currentY = touch.clientY
  touchState.currentX = touch.clientX
  touchState.isTouching = true
  touchState.touchStartTime = Date.now()
  touchState.isLongPress = false
  
  // 長按檢測
  touchState.longPressTimer = setTimeout(() => {
    if (touchState.isTouching) {
      touchState.isLongPress = true
      startTouchDrag(index)
      
      // 觸覺反饋
      if ('vibrate' in navigator) {
        navigator.vibrate(50)
      }
    }
  }, 500)
  
  event.preventDefault()
}

const handleTouchMove = (event: TouchEvent) => {
  if (!touchState.isTouching) return
  
  const touch = event.touches[0]
  touchState.currentY = touch.clientY
  touchState.currentX = touch.clientX
  
  const deltaY = Math.abs(touchState.currentY - touchState.startY)
  const deltaX = Math.abs(touchState.currentX - touchState.startX)
  
  // 如果移動距離超過閾值，取消長按
  if ((deltaY > 10 || deltaX > 10) && touchState.longPressTimer) {
    clearTimeout(touchState.longPressTimer)
    touchState.longPressTimer = null
  }
  
  if (touchState.isLongPress && dragState.isDragging) {
    // 更新拖拽位置
    const draggedElement = document.querySelector('.draggable-item.is-dragging')
    if (draggedElement) {
      const rect = draggedElement.getBoundingClientRect()
      const translateY = touchState.currentY - touchState.startY
      
      // 找到最接近的拖放目標
      const items = document.querySelectorAll('.draggable-item')
      let closestIndex = -1
      let closestDistance = Infinity
      
      items.forEach((item, index) => {
        const itemRect = item.getBoundingClientRect()
        const itemCenter = itemRect.top + itemRect.height / 2
        const distance = Math.abs(itemCenter - touchState.currentY)
        
        if (distance < closestDistance) {
          closestDistance = distance
          closestIndex = index
        }
      })
      
      if (closestIndex !== -1 && closestIndex !== dragState.draggedIndex) {
        dragState.dragOverIndex = closestIndex
      }
    }
  }
  
  event.preventDefault()
}

const handleTouchEnd = () => {
  if (touchState.longPressTimer) {
    clearTimeout(touchState.longPressTimer)
    touchState.longPressTimer = null
  }
  
  if (touchState.isLongPress && dragState.isDragging) {
    // 完成拖拽
    if (dragState.dragOverIndex !== -1 && dragState.dragOverIndex !== dragState.draggedIndex) {
      reorderItems(dragState.draggedIndex, dragState.dragOverIndex)
    }
    
    handleDragEnd()
  }
  
  touchState.isTouching = false
  touchState.isLongPress = false
}

const startTouchDrag = (index: number) => {
  dragState.isDragging = true
  dragState.draggedIndex = index
  dragState.draggedItem = props.items[index]
}

// 重新排序
const reorderItems = async (fromIndex: number, toIndex: number) => {
  if (fromIndex === toIndex) return
  
  const newItems = [...props.items]
  const draggedItem = newItems.splice(fromIndex, 1)[0]
  newItems.splice(toIndex, 0, draggedItem)
  
  // 添加動畫
  animatingItems.value.add(fromIndex)
  animatingItems.value.add(toIndex)
  
  emit('update:items', newItems)
  emit('item-reordered', fromIndex, toIndex)
  
  // 清除動畫狀態
  setTimeout(() => {
    animatingItems.value.delete(fromIndex)
    animatingItems.value.delete(toIndex)
  }, props.animationDuration)
}

// 刪除項目
const removeItem = async (index: number) => {
  const item = props.items[index]
  const newItems = props.items.filter((_, i) => i !== index)
  
  // 添加動畫
  animatingItems.value.add(index)
  
  emit('update:items', newItems)
  emit('item-removed', item, index)
  
  // 清除動畫狀態
  setTimeout(() => {
    animatingItems.value.delete(index)
  }, props.animationDuration)
}

// 獲取項目樣式
const getItemStyle = (index: number) => {
  const styles: Record<string, string> = {}
  
  if (dragState.draggedIndex === index && dragState.isDragging) {
    styles.transform = 'scale(1.05)'
    styles.opacity = '0.8'
    styles.zIndex = '10'
  }
  
  if (touchState.isLongPress && dragState.draggedIndex === index) {
    const translateY = touchState.currentY - touchState.startY
    styles.transform = `translateY(${translateY}px) scale(1.05)`
    styles.opacity = '0.9'
    styles.zIndex = '20'
  }
  
  return styles
}
</script>

<style scoped>
.draggable-list {
  @apply space-y-3;
}

.draggable-item {
  @apply relative bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-xl p-4 group;
}

.draggable-item.is-dragging {
  @apply shadow-2xl ring-2 ring-blue-400;
}

.draggable-item.is-drag-over {
  @apply ring-2 ring-blue-400 ring-opacity-50;
}

.draggable-item.is-animating {
  @apply transform transition-all duration-300;
}

.item-content {
  @apply relative min-h-[60px] flex items-center;
}

.drag-handle {
  @apply opacity-0 group-hover:opacity-100 transition-opacity duration-200;
}

.insert-indicator {
  @apply animate-pulse;
}

.empty-state {
  @apply border-2 border-dashed border-gray-300 rounded-xl;
}

/* 觸控設備優化 */
@media (hover: none) {
  .drag-handle {
    @apply opacity-100;
  }
  
  .draggable-item {
    @apply hover:transform-none;
  }
}

/* 動畫效果 */
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

.draggable-item.is-animating {
  animation: shake 0.5s ease-in-out;
}
</style>