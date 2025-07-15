<template>
  <div class="markdown-editor">
    <div class="editor-tabs mb-4">
      <button
        @click="activeTab = 'edit'"
        :class="[
          'px-4 py-2 border-b-2 font-medium text-sm',
          activeTab === 'edit' 
            ? 'border-blue-500 text-blue-600' 
            : 'border-transparent text-gray-500 hover:text-gray-700'
        ]"
      >
        編輯
      </button>
      <button
        @click="activeTab = 'preview'"
        :class="[
          'px-4 py-2 border-b-2 font-medium text-sm ml-6',
          activeTab === 'preview' 
            ? 'border-blue-500 text-blue-600' 
            : 'border-transparent text-gray-500 hover:text-gray-700'
        ]"
      >
        預覽
      </button>
      <button
        @click="activeTab = 'split'"
        :class="[
          'px-4 py-2 border-b-2 font-medium text-sm ml-6',
          activeTab === 'split' 
            ? 'border-blue-500 text-blue-600' 
            : 'border-transparent text-gray-500 hover:text-gray-700'
        ]"
      >
        分割預覽
      </button>
    </div>

    <div class="editor-content">
      <!-- 編輯模式 -->
      <div v-if="activeTab === 'edit'" class="edit-mode">
        <textarea
          v-model="content"
          @input="handleInput"
          :placeholder="placeholder"
          :rows="rows"
          class="form-input resize-none"
          :style="{ height: `${rows * 1.5}rem` }"
        />
        <div class="text-xs text-gray-500 mt-2">
          支援 Markdown 語法：**粗體**、*斜體*、# 標題、- 列表、[連結](網址)、```程式碼```
        </div>
      </div>

      <!-- 預覽模式 -->
      <div v-else-if="activeTab === 'preview'" class="preview-mode">
        <div 
          class="markdown-preview border border-gray-300 rounded-md p-4 bg-gray-50 min-h-[200px]"
          v-html="renderedContent"
        />
      </div>

      <!-- 分割預覽模式 -->
      <div v-else class="split-mode grid grid-cols-2 gap-4">
        <div class="edit-panel">
          <div class="text-sm font-medium text-gray-700 mb-2">編輯</div>
          <textarea
            v-model="content"
            @input="handleInput"
            :placeholder="placeholder"
            :rows="rows"
            class="form-input resize-none"
            :style="{ height: `${rows * 1.5}rem` }"
          />
        </div>
        <div class="preview-panel">
          <div class="text-sm font-medium text-gray-700 mb-2">預覽</div>
          <div 
            class="markdown-preview border border-gray-300 rounded-md p-4 bg-gray-50"
            :style="{ height: `${rows * 1.5}rem`, overflow: 'auto' }"
            v-html="renderedContent"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { marked } from 'marked'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'

interface Props {
  modelValue: string
  placeholder?: string
  rows?: number
}

interface Emits {
  (e: 'update:modelValue', value: string): void
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: '請輸入內容...',
  rows: 12
})

const emit = defineEmits<Emits>()

const activeTab = ref<'edit' | 'preview' | 'split'>('edit')
const content = ref(props.modelValue)

// 設定 marked 選項
marked.setOptions({
  highlight: function(code, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(code, { language: lang }).value
      } catch (__) {}
    }
    return hljs.highlightAuto(code).value
  },
  breaks: true,
  gfm: true
})

const renderedContent = computed(() => {
  if (!content.value) return '<p class="text-gray-500 italic">暫無內容</p>'
  
  try {
    return marked(content.value)
  } catch (error) {
    console.error('Markdown parsing error:', error)
    return '<p class="text-red-500">Markdown 解析錯誤</p>'
  }
})

function handleInput() {
  emit('update:modelValue', content.value)
}

// 監聽外部變化
watch(() => props.modelValue, (newValue) => {
  content.value = newValue
}, { immediate: true })
</script>

<style scoped>
.markdown-editor {
  @apply w-full;
}

.editor-tabs {
  @apply border-b border-gray-200;
}

.markdown-preview {
  @apply prose prose-sm max-w-none;
}

.markdown-preview :deep(h1) {
  @apply text-xl font-bold mb-4 mt-6 text-gray-900;
}

.markdown-preview :deep(h2) {
  @apply text-lg font-semibold mb-3 mt-5 text-gray-800;
}

.markdown-preview :deep(h3) {
  @apply text-base font-medium mb-2 mt-4 text-gray-700;
}

.markdown-preview :deep(p) {
  @apply mb-4 text-gray-700 leading-relaxed;
}

.markdown-preview :deep(ul) {
  @apply list-disc list-inside mb-4 text-gray-700;
}

.markdown-preview :deep(ol) {
  @apply list-decimal list-inside mb-4 text-gray-700;
}

.markdown-preview :deep(li) {
  @apply mb-1;
}

.markdown-preview :deep(blockquote) {
  @apply border-l-4 border-gray-300 pl-4 italic text-gray-600 mb-4;
}

.markdown-preview :deep(code) {
  @apply bg-gray-100 px-1 py-0.5 rounded text-sm font-mono text-red-600;
}

.markdown-preview :deep(pre) {
  @apply bg-gray-100 p-4 rounded-md overflow-x-auto mb-4;
}

.markdown-preview :deep(pre code) {
  @apply bg-transparent p-0 text-gray-800;
}

.markdown-preview :deep(a) {
  @apply text-blue-600 hover:text-blue-800 underline;
}

.markdown-preview :deep(strong) {
  @apply font-bold text-gray-900;
}

.markdown-preview :deep(em) {
  @apply italic;
}

.markdown-preview :deep(table) {
  @apply border-collapse border border-gray-300 mb-4 w-full;
}

.markdown-preview :deep(th) {
  @apply border border-gray-300 px-3 py-2 bg-gray-50 font-medium text-left;
}

.markdown-preview :deep(td) {
  @apply border border-gray-300 px-3 py-2;
}

.markdown-preview :deep(hr) {
  @apply border-t border-gray-300 my-6;
}
</style>