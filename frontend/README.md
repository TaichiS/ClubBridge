# ClubBridge Frontend

ClubBridge 跨校選社系統前端應用程式

## 🚀 快速開始

### 環境需求

- Node.js 18+ 
- npm 9+

### 安裝與啟動

```bash
# 安裝依賴
npm install

# 啟動開發伺服器
npm run dev

# 建置正式版本
npm run build

# 預覽建置結果
npm run preview
```

### 環境變數設定

複製 `.env.example` 為 `.env.local` 並填入實際值：

```bash
cp .env.example .env.local
```

必要的環境變數：
- `VITE_API_BASE_URL` - 後端 API 基礎 URL
- `VITE_GOOGLE_CLIENT_ID` - Google OAuth Client ID

## 🏗 技術架構

### 核心技術

- **前端框架**: Vue 3 + TypeScript
- **建置工具**: Vite
- **狀態管理**: Pinia
- **路由**: Vue Router
- **樣式**: Tailwind CSS
- **圖示**: Heroicons
- **認證**: Google OAuth + 自訂學生認證

### 專案結構

```
src/
├── api/              # API 客戶端
├── assets/           # 靜態資源
├── components/       # Vue 元件
├── composables/      # 組合式函數
├── layouts/          # 版面配置
├── pages/            # 頁面元件
├── router/           # 路由設定
├── stores/           # Pinia 狀態管理
├── types/            # TypeScript 類型定義
└── utils/            # 工具函數
```

## 🔐 認證系統

### 支援的認證方式

1. **Google OAuth** - 適用於管理員、老師
2. **學生登入** - 使用學號 + 身分證字號

### 使用者角色

- `super_admin` - 超級管理員
- `school_admin` - 學校管理員  
- `teacher` - 社團老師
- `student` - 學生

### 權限管理

基於角色的訪問控制 (RBAC) + 多租戶資料隔離

## 🎨 UI 設計系統

### 色彩系統

- **Primary**: 藍色系 (#0ea5e9)
- **Secondary**: 灰色系 (#71717a)
- **成功**: 綠色系
- **警告**: 黃色系  
- **錯誤**: 紅色系

### 元件命名規範

- `btn-primary` - 主要按鈕
- `btn-secondary` - 次要按鈵
- `card` - 卡片容器
- `form-input` - 表單輸入
- `form-label` - 表單標籤

## 📱 響應式設計

- **手機版**: < 768px
- **平板版**: 768px - 1024px  
- **桌面版**: > 1024px

## 🛠 開發指令

```bash
# 開發
npm run dev

# 型別檢查
npm run type-check

# 程式碼檢查
npm run lint

# 程式碼格式化
npm run format

# 測試
npm run test:unit

# 建置
npm run build
```

## 📚 開發文件

- [認證系統報告](./docs/AUTH_SYSTEM_REPORT.md)
- [前端開發日誌](../docs/FRONTEND_DEVELOPMENT_LOG.md)
- [API 整合指南](./docs/API_INTEGRATION.md) (待建立)

## 🧪 測試

```bash
# 單元測試
npm run test:unit

# E2E 測試  
npm run test:e2e

# 測試覆蓋率
npm run test:coverage
```

## 🚀 部署

### 開發環境

```bash
npm run dev
```

### 正式環境

```bash
npm run build
npm run preview
```

### Docker 部署

```bash
# 建立映像檔
docker build -t clubbridge-frontend .

# 執行容器
docker run -p 5173:5173 clubbridge-frontend
```

## 🔧 故障排除

### 常見問題

1. **Tailwind CSS 樣式未載入**
   - 檢查 `tailwind.config.cjs` 設定
   - 確認 `main.css` 正確匯入

2. **Google OAuth 登入失敗**
   - 檢查 `VITE_GOOGLE_CLIENT_ID` 環境變數
   - 確認網域名稱已加入 Google Console

3. **API 請求失敗**
   - 檢查 `VITE_API_BASE_URL` 設定
   - 確認後端服務正常運行

### 除錯模式

```bash
# 啟用 Vue DevTools
VITE_ENABLE_DEVTOOLS=true npm run dev
```

## 🤝 開發流程

### Git 工作流程

1. 從 `main` 分支建立功能分支
2. 完成開發並撰寫測試
3. 提交 Pull Request
4. Code Review 通過後合併

### 程式碼規範

- 使用 ESLint + Prettier
- 遵循 Vue 3 最佳實踐
- TypeScript 嚴格模式
- 組合式函數命名以 `use` 開頭

## 📦 相依套件

### 生產依賴

```json
{
  "vue": "^3.5.17",
  "vue-router": "^4.5.1", 
  "pinia": "^3.0.3",
  "axios": "^1.10.0",
  "@heroicons/vue": "^2.2.0",
  "@vueuse/core": "^13.5.0"
}
```

### 開發依賴

```json
{
  "vite": "^7.0.0",
  "typescript": "~5.8.0",
  "tailwindcss": "^3.4.17",
  "eslint": "^9.29.0",
  "prettier": "3.5.3"
}
```

## 📄 授權

MIT License - 詳見 [LICENSE](../LICENSE) 檔案

## 🙋‍♂️ 支援

如有問題請聯絡：
- 開發團隊: dev@clubbridge.com
- 技術支援: support@clubbridge.com

---

**ClubBridge Frontend v1.0.0** - 現代化跨校選社系統前端應用
