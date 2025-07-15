import { marked } from 'marked'
import hljs from 'highlight.js'

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

export function useMarkdown() {
  const renderMarkdown = (content: string | null | undefined): string => {
    if (!content) return ''
    
    try {
      return marked(content)
    } catch (error) {
      console.error('Markdown parsing error:', error)
      return content // 如果解析失敗，回傳原始內容
    }
  }

  return {
    renderMarkdown
  }
}