# 學生系統開發 TODO 清單

## 📋 專案概述
建立完全獨立的學生選社系統，包含學校公開資訊、社團資訊展示、學生登入選社等功能。

## 🎯 核心目標
- 將學生系統與管理員系統完全分離
- 提供學校和社團的公開資訊展示
- 實現學生登入和選社功能
- 支援獨立部署在不同網域

## 📁 資料夾結構設計
```
frontend/src/student/
├── pages/
│   ├── SchoolHomePage.vue          # 學校首頁（公開）
│   ├── ClubsPage.vue               # 社團總覽（公開）
│   ├── ClubDetailPage.vue          # 社團詳情（公開）
│   ├── LoginPage.vue               # 學生登入頁面
│   ├── SelectionPage.vue           # 選社頁面（需登入）
│   └── ResultPage.vue              # 選社結果（需登入）
├── components/
│   ├── SchoolInfo.vue              # 學校基本資訊組件
│   ├── AnnouncementList.vue        # 公告列表組件
│   ├── ClubCard.vue                # 社團卡片組件
│   ├── ClubFilter.vue              # 社團篩選組件
│   └── SelectionStatus.vue         # 選社狀態組件
├── composables/
│   ├── useSchoolInfo.ts            # 學校資訊邏輯
│   ├── useClubInfo.ts              # 社團資訊邏輯
│   ├── useStudentAuth.ts           # 學生認證邏輯
│   └── useSelection.ts             # 選社邏輯
├── api/
│   ├── publicApi.ts                # 公開資訊 API
│   └── studentApi.ts               # 學生專用 API
└── types/
    ├── school.ts                   # 學校相關類型
    ├── club.ts                     # 社團相關類型
    └── student.ts                  # 學生相關類型
```

## 🌐 URL 路由設計
```
https://student.clubbridge.com/school/ABC/
├── /                               # 學校首頁
├── /clubs                          # 社團總覽
├── /clubs/:id                      # 社團詳情
├── /login                          # 學生登入
├── /selection                      # 選社頁面（需登入）
└── /result                         # 選社結果（需登入）
```

## 📊 資料結構設計

### 學校公開資訊
```typescript
interface SchoolPublicInfo {
  id: string
  name: string
  logo: string
  description: string
  announcements: Announcement[]
  selectionSchedule: SelectionSchedule
  clubStats: ClubStats
}

interface Announcement {
  id: string
  title: string
  content: string
  createdAt: Date
  priority: 'high' | 'medium' | 'low'
}

interface SelectionSchedule {
  registrationStart: Date
  registrationEnd: Date
  assignmentDate: Date
  resultAnnouncement: Date
}
```

### 社團公開資訊
```typescript
interface ClubPublicInfo {
  id: string
  name: string
  category: string
  teacher: string
  description: string
  maxCapacity: number
  currentCount: number
  location: string
  rainLocation?: string
  requirements: ClubRequirements
  schedule: string
  images?: string[]
}

interface ClubRequirements {
  gender?: 'male' | 'female' | 'both'
  grade?: string[]
  special?: string
}
```

## 🔧 API 端點設計

### 公開 API（無需認證）
```
GET /api/public/schools/:schoolId/info          # 學校基本資訊
GET /api/public/schools/:schoolId/announcements # 學校公告
GET /api/public/schools/:schoolId/clubs         # 社團列表
GET /api/public/schools/:schoolId/clubs/:clubId # 社團詳情
GET /api/public/schools/:schoolId/schedule      # 選社時程
```

### 學生 API（需認證）
```
POST /api/student/login                         # 學生登入
GET /api/student/profile                        # 學生資訊
POST /api/student/selection                     # 提交選社志願
GET /api/student/selection                      # 查看選社結果
```

## ✅ 開發任務清單

### 🔥 高優先級任務
- [ ] 1. 建立學生系統基礎資料夾結構
- [ ] 2. 定義學校和社團相關的 TypeScript 類型
- [ ] 3. 建立公開資訊 API 端點
- [ ] 4. 實作學校首頁組件 (SchoolHomePage.vue)
- [ ] 5. 實作社團總覽頁面 (ClubsPage.vue)

### 🟡 中優先級任務
- [ ] 6. 實作社團詳情頁面 (ClubDetailPage.vue)
- [ ] 7. 實作學生登入頁面 (LoginPage.vue)
- [ ] 8. 實作選社頁面 (SelectionPage.vue)
- [ ] 9. 實作選社結果頁面 (ResultPage.vue)
- [ ] 10. 建立學校資訊相關 composables
- [ ] 11. 建立社團資訊相關 composables
- [ ] 12. 建立學生認證相關 composables
- [ ] 13. 設置學生系統路由配置

### 🔵 低優先級任務
- [ ] 14. 實作公告列表組件 (AnnouncementList.vue)
- [ ] 15. 實作社團卡片組件 (ClubCard.vue)
- [ ] 16. 實作社團篩選組件 (ClubFilter.vue)
- [ ] 17. 實作選社狀態組件 (SelectionStatus.vue)
- [ ] 18. 測試和優化學生系統功能

## 📋 頁面功能詳細規劃

### 🏫 學校首頁（公開）
- 學校基本資訊（校名、校徽、簡介）
- 重要公告列表
- 選社時程資訊
- 社團總數統計
- 快速導航按鈕

### 🎭 社團總覽頁面（公開）
- 社團列表展示
- 篩選功能：
  - 按類別篩選（體育、藝文、學術等）
  - 按年級限制篩選
  - 按人數餘額篩選
  - 搜尋功能
- 社團基本資訊卡片
- 即時人數統計

### 🎨 社團詳情頁面（公開）
- 社團完整資訊
- 指導老師資訊
- 活動地點、時間
- 招收條件
- 目前報名狀況
- 相關公告

### 🔑 學生登入頁面
- 學號 + 身分證登入
- 學校資訊展示
- 選社時程提醒
- 登入後導向選社頁面

### 🎯 選社頁面（需登入）
- 志願序拖拉排序
- 社團篩選和搜尋
- 即時人數顯示
- 選社條件檢查
- 提交志願功能

### 📊 選社結果頁面（需登入）
- 最終分配結果
- 社團資訊
- 聯繫方式
- 相關公告

## 🚀 技術考量

### 獨立部署考量
- 不使用 Pinia（使用 Vue 3 Composition API）
- 獨立的 package.json
- 可部署在不同網域
- 輕量化依賴

### 效能優化
- 公開資訊快取
- 圖片懶加載
- 分頁載入
- 響應式設計

### 安全考量
- 學生資料保護
- API 限流
- 輸入驗證
- XSS 防護

## 📝 開發筆記
- 此 TODO 檔案應隨開發進度持續更新
- 完成的任務請標記為已完成
- 遇到的問題和解決方案請記錄在此
- 重要的技術決策和原因請記錄在此

---

**最後更新：** 2025-07-14
**狀態：** 規劃階段
**下一步：** 開始執行高優先級任務