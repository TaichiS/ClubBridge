# ClubBridge - 跨校選社系統

這是一個使用 Ruby on Rails 8 開發的 API-only 後端專案，旨在實現一個多租戶（multi-tenant）的跨校選社系統。

詳細的系統規劃請參考 `Claude.md` 文件。

---

## 🚧 開發進度

### ✅ v0.1: 學校申請與審核 API (已完成)

- **框架與測試:**
  - 整合 `rspec-rails` 作為測試框架。
  - 建立初步的測試環境。
- **核心模型:**
  - 建立 `School` 模型，包含 `name` 與 `status` 屬性。
  - 使用 `enum` 管理審核狀態 (`pending`, `approved`, `rejected`)。
  - 加入 `name` 的存在性驗證。
- **API 端點:**
  - `POST /api/schools/apply`: 讓使用者申請建立新學校。
  - `GET /api/admin/schools/pending`: 讓超級管理員檢視待審核學校。
  - `POST /api/admin/schools/:id/approve`: 讓超級管理員核准學校申請。
- **測試:**
  - 為所有 API 端點編寫了完整的請求測試 (Request Specs)，涵蓋成功與失敗情境。
  - 所有測試均已通過。

---

### 📝 下一步計畫：學期初設定 (管理員功能)

這是下一個開發階段的計畫，主要專注於學校管理員在學期初需要用到的設定功能。

- [ ] **學生資料管理**
  - [ ] 根據規格書建立 `Student` 模型 (10個欄位)。
  - [ ] 實作 `acts_as_tenant`，讓學生資料隸屬於特定學校。
  - [ ] 實作 `POST /api/schools/:school_id/students/import` API，支援從 Excel 大量匯入學生。
  - [ ] 實作學生資料的 CRUD API (`/api/schools/:school_id/students`)。
- [ ] **社團資料管理**
  - [ ] 根據規格書建立 `Club` 模型 (13個欄位)。
  - [ ] 實作 `acts_as_tenant`，讓社團資料隸屬於特定學校。
  - [ ] 實作 `POST /api/schools/:school_id/clubs/import` API，支援從 Excel 大量匯入社團。
  - [ ] 實作社團資料的 CRUD API (`/api/schools/:school_id/clubs`)。
- [ ] **系統設定**
  - [ ] 實作設定「進站說明」的 API。
  - [ ] 實作設定「活動日期」的 API。
- [ ] **認證與授權**
  - [ ] 建立初步的學校管理員認證機制，以保護上述 API。
