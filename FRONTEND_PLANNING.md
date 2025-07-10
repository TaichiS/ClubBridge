# 🎨 ClubBridge 前端開發規劃文件

## 📋 專案概述

基於 Rails API 後端的跨校選社系統前端實作，採用現代化前端技術堆疊。

### 🛠 技術堆疊

```
Vite + Vue3 + TypeScript + Pinia + Vue Router + Tailwind CSS + shadcn/vue + Heroicons + Motion for Vue
```

---

## 🏗 專案架構

### 📁 目錄結構設計

```
frontend/
├── public/
│   ├── favicon.ico
│   └── index.html
├── src/
│   ├── assets/           # 靜態資源
│   │   ├── images/
│   │   └── icons/
│   ├── components/       # 全域元件
│   │   ├── ui/          # shadcn/vue 基礎 UI 元件
│   │   ├── forms/       # 表單相關元件
│   │   ├── charts/      # 圖表元件
│   │   └── common/      # 通用元件
│   ├── composables/     # Vue 3 組合式函數
│   │   ├── useAuth.ts
│   │   ├── useApi.ts
│   │   └── useUtils.ts
│   ├── layouts/         # 版面配置
│   │   ├── DefaultLayout.vue
│   │   ├── AdminLayout.vue
│   │   ├── TeacherLayout.vue
│   │   └── StudentLayout.vue
│   ├── pages/           # 頁面元件
│   │   ├── public/      # 公開頁面
│   │   ├── admin/       # 管理員頁面
│   │   ├── teacher/     # 老師頁面
│   │   └── student/     # 學生頁面
│   ├── stores/          # Pinia 狀態管理
│   │   ├── auth.ts
│   │   ├── school.ts
│   │   ├── student.ts
│   │   ├── club.ts
│   │   └── application.ts
│   ├── router/          # Vue Router
│   │   ├── index.ts
│   │   └── guards.ts
│   ├── api/             # API 客戶端
│   │   ├── client.ts
│   │   ├── auth.ts
│   │   ├── school.ts
│   │   ├── student.ts
│   │   └── club.ts
│   ├── types/           # TypeScript 類型定義
│   │   ├── auth.ts
│   │   ├── school.ts
│   │   ├── student.ts
│   │   └── club.ts
│   ├── utils/           # 工具函數
│   │   ├── format.ts
│   │   ├── validation.ts
│   │   └── excel.ts
│   ├── styles/          # 全域樣式
│   │   ├── globals.css
│   │   └── components.css
│   ├── App.vue
│   └── main.ts
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── tsconfig.json
└── README.md
```

---

## 🎯 核心功能模組

### 1. 🔐 認證系統

**雙軌認證機制：**
- Google OAuth2（管理員、老師）
- 學號+身分證（學生）

**權限管理：**
- 超級管理員：全域系統管理
- 學校管理員：學校範圍管理
- 社團老師：社團範圍管理
- 學生：個人資料與選社

### 2. 🏫 多租戶支援

**URL 結構：**
```
https://domain.com/schools/ABC123/admin
https://domain.com/schools/ABC123/student
https://domain.com/schools/ABC123/teacher
```

**資料隔離：**
- 根據 URL 參數或子網域識別學校
- 所有 API 請求自動帶入學校 ID
- 前端路由守衛確保權限隔離

### 3. 📱 響應式設計

**斷點設計：**
- 手機版：< 768px
- 平板版：768px - 1024px
- 桌面版：> 1024px

**移動端優化：**
- 觸控友好的拖拉排序
- 簡化的導航選單
- 適配手機的表單設計

---

## 🎨 使用者介面設計

### 🌟 公開區域

**首頁 (`/`)**
- 系統介紹與特色
- 學校申請入口
- 系統狀態展示

**學校申請頁 (`/apply`)**
- Google OAuth 登入
- 學校資訊填寫表單
- 申請狀態追蹤

### 👑 超級管理員區域

**管理後台 (`/admin`)**
- 學校申請審核列表
- 系統統計儀表板
- 使用者管理

### 🏫 學校管理員區域

**學校後台 (`/schools/:id/admin`)**

**學期初設定：**
- 學生資料匯入（Excel）
- 社團資料匯入（Excel）
- 系統設定（日期、公告）
- 資料備份與匯出

**選社期間管理：**
- 即時統計儀表板
- 未選社學生名單
- 學生解鎖重選功能
- 分發啟動控制

**結果管理：**
- 選社結果查詢
- 各種報表匯出
- 轉社申請處理

### 👩‍🏫 社團老師區域

**老師後台 (`/schools/:id/teacher`)**
- 社團學生名單
- 課程點名系統
- 成績輸入介面
- 社團活動記錄

### 🧑‍🎓 學生區域

**學生介面 (`/schools/:id/student`)**
- 學號+身分證登入
- 社團瀏覽與搜尋
- 志願選擇（拖拉排序）
- 選社結果查看

---

## 🔄 狀態管理架構

### Pinia Stores 設計

```typescript
// stores/auth.ts
export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: null,
    role: null,
    school: null
  }),
  actions: {
    async login(credentials),
    async logout(),
    async refreshToken()
  }
})

// stores/school.ts
export const useSchoolStore = defineStore('school', {
  state: () => ({
    current: null,
    settings: null,
    applications: []
  }),
  actions: {
    async fetchSchool(id),
    async updateSettings(settings),
    async getApplications()
  }
})

// stores/student.ts
export const useStudentStore = defineStore('student', {
  state: () => ({
    students: [],
    currentStudent: null,
    filters: {}
  }),
  actions: {
    async fetchStudents(),
    async importStudents(file),
    async updateStudent(student)
  }
})

// stores/club.ts
export const useClubStore = defineStore('club', {
  state: () => ({
    clubs: [],
    currentClub: null,
    statistics: null
  }),
  actions: {
    async fetchClubs(),
    async importClubs(file),
    async getStatistics()
  }
})

// stores/application.ts
export const useApplicationStore = defineStore('application', {
  state: () => ({
    applications: [],
    currentApplication: null,
    assignments: []
  }),
  actions: {
    async submitApplication(choices),
    async getAssignments(),
    async startAssignment()
  }
})
```

---

## 🛣 路由設計

### Vue Router 結構

```typescript
// router/index.ts
const routes = [
  // 公開路由
  { path: '/', component: HomePage },
  { path: '/apply', component: ApplyPage },
  
  // 超級管理員路由
  { 
    path: '/admin', 
    component: AdminLayout,
    meta: { requiresAuth: true, role: 'super_admin' },
    children: [
      { path: '', component: AdminDashboard },
      { path: 'schools', component: SchoolManagement },
      { path: 'users', component: UserManagement }
    ]
  },
  
  // 學校路由
  {
    path: '/schools/:schoolId',
    component: SchoolLayout,
    meta: { requiresAuth: true },
    children: [
      // 學校管理員
      {
        path: 'admin',
        component: SchoolAdminLayout,
        meta: { role: 'school_admin' },
        children: [
          { path: '', component: SchoolDashboard },
          { path: 'students', component: StudentManagement },
          { path: 'clubs', component: ClubManagement },
          { path: 'settings', component: SchoolSettings },
          { path: 'statistics', component: Statistics }
        ]
      },
      
      // 社團老師
      {
        path: 'teacher',
        component: TeacherLayout,
        meta: { role: 'teacher' },
        children: [
          { path: '', component: TeacherDashboard },
          { path: 'attendance', component: AttendanceManagement },
          { path: 'grades', component: GradeManagement }
        ]
      },
      
      // 學生
      {
        path: 'student',
        component: StudentLayout,
        meta: { role: 'student' },
        children: [
          { path: '', component: StudentDashboard },
          { path: 'login', component: StudentLogin },
          { path: 'choose', component: ClubSelection },
          { path: 'result', component: SelectionResult }
        ]
      }
    ]
  }
]
```

---

## 🔗 API 整合

### HTTP 客戶端設計

```typescript
// api/client.ts
import axios from 'axios'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000
})

// 請求攔截器
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 響應攔截器
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // 處理認證失敗
      useAuthStore().logout()
    }
    return Promise.reject(error)
  }
)
```

---

## 🎯 UI/UX 重點功能

### 1. 學生選社介面

**志願拖拉排序：**
- 使用 Vue.Draggable 實作
- 視覺化拖拉提示
- 即時保存功能

**社團瀏覽：**
- 篩選與搜尋功能
- 社團詳細資訊彈窗
- 收藏功能

### 2. 即時統計圖表

**技術選擇：**
- Chart.js 或 ECharts
- 實時數據更新
- 響應式圖表設計

**統計內容：**
- 各社團報名人數
- 選社進度統計
- 歷史趨勢分析

### 3. Excel 匯入功能

**前端處理：**
- 使用 SheetJS 解析 Excel
- 資料驗證與錯誤提示
- 匯入進度顯示

### 4. 響應式設計

**手機版優化：**
- 側邊選單摺疊
- 表格橫向滾動
- 觸控友好按鈕

---

## 🧪 測試策略

### 測試工具

```json
{
  "devDependencies": {
    "vitest": "^1.0.0",
    "@vue/test-utils": "^2.0.0",
    "jsdom": "^21.0.0",
    "cypress": "^12.0.0"
  }
}
```

### 測試範圍

**單元測試：**
- 組合式函數測試
- 工具函數測試
- Pinia store 測試

**元件測試：**
- UI 元件互動測試
- 表單驗證測試
- 路由導航測試

**E2E 測試：**
- 使用者流程測試
- 跨瀏覽器相容性測試

---

## 🚀 建置與部署

### 開發環境設定

```bash
# 環境變數設定
VITE_API_BASE_URL=http://localhost:3000
VITE_GOOGLE_CLIENT_ID=your_google_client_id
VITE_APP_ENV=development
```

### 建置流程

```bash
# 開發
npm run dev

# 建置
npm run build

# 預覽
npm run preview

# 測試
npm run test
npm run test:e2e
```

### 部署設定

**靜態檔案托管：**
- Netlify / Vercel
- AWS S3 + CloudFront
- 自架 Nginx

**CI/CD 流程：**
- GitHub Actions
- 自動化測試
- 自動化部署

---

## 📝 開發里程碑

### 階段一：基礎架構（1-2週）
- [x] 專案初始化
- [ ] 技術堆疊設定
- [ ] 路由與狀態管理
- [ ] 認證系統
- [ ] API 客戶端

### 階段二：核心功能（2-3週）
- [ ] 公開頁面
- [ ] 管理員後台
- [ ] 學生選社介面
- [ ] 老師管理介面

### 階段三：進階功能（2-3週）
- [ ] 即時統計
- [ ] Excel 匯入
- [ ] 響應式設計
- [ ] 動畫效果

### 階段四：測試與最佳化（1-2週）
- [ ] 測試覆蓋率
- [ ] 效能最佳化
- [ ] 瀏覽器相容性
- [ ] 部署上線

---

## 🔧 技術細節

### 依賴套件清單

```json
{
  "dependencies": {
    "vue": "^3.4.0",
    "vue-router": "^4.2.0",
    "pinia": "^2.1.0",
    "@vueuse/core": "^10.0.0",
    "axios": "^1.6.0",
    "tailwindcss": "^3.4.0",
    "shadcn-vue": "^0.10.0",
    "@heroicons/vue": "^2.0.0",
    "@vueuse/motion": "^2.0.0",
    "vue-draggable-plus": "^0.3.0",
    "chart.js": "^4.4.0",
    "vue-chartjs": "^5.3.0",
    "xlsx": "^0.18.0",
    "dayjs": "^1.11.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.6.0",
    "vite": "^5.0.0",
    "typescript": "^5.3.0",
    "vitest": "^1.0.0",
    "@vue/test-utils": "^2.4.0",
    "jsdom": "^21.0.0",
    "cypress": "^12.17.0",
    "eslint": "^8.56.0",
    "prettier": "^3.1.0"
  }
}
```

### 環境配置

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  }
})
```

---

## 📚 文件與資源

### 開發文件
- [ ] 元件使用指南
- [ ] API 整合文件
- [ ] 部署操作手冊
- [ ] 故障排除指南

### 設計資源
- [ ] UI 設計規範
- [ ] 色彩與字體指南
- [ ] 圖示使用規範
- [ ] 響應式設計指南

---

這份規劃文件將作為前端開發的完整指南，確保專案能夠有序進行並達到預期目標。隨著開發進展，將持續更新和完善此文件。