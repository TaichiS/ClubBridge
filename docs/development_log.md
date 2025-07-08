# 開發日誌與問題報告 (2025-07-08)

**主題：學生資料管理功能 - CRUD 及 Excel 匯入**

## 🎯 本次目標

完成學生資料的完整生命週期管理，包括：
1.  建立 `Student` 模型並整合多租戶 (`acts_as_tenant`)。
2.  實作完整的 CRUD (Create, Read, Update, Delete) API。
3.  實作透過 Excel 檔案大量匯入學生資料的功能。
4.  為所有功能編寫完整的 RSpec 測試。

## ✅ 工作成果

我們成功完成了本次設定的所有目標。

1.  **模型與多租戶**:
    - 建立了 `Student` 模型，包含規格書中定義的所有欄位。
    - 在 `Student` 模型中設定了 `belongs_to :school` 關聯。
    - 在 `School` 模型中設定了 `has_many :students` 關聯。
    - 成功整合 `acts_as_tenant`，在 `ApplicationController` 中設定了租戶過濾，確保所有學生資料都根據 `school_id` 進行了隔離。

2.  **CRUD API**:
    - 實作了 `/api/schools/:school_id/students` 的 `index`, `create`, `update`, `destroy` 四個端點。
    - 撰寫了對應的請求測試，驗證了 API 功能及多租戶資料隔離的正確性。

3.  **Excel 匯入功能**:
    - 整合了 `roo` 和 `caxlsx` (取代已過時的 `axlsx`) gem 用於處理 Excel 檔案。
    - 實作了 `POST /api/schools/:school_id/students/import` API 端點。
    - 建立了 Rake 任務 (`test:generate_fixtures`) 以便於產生測試用的 Excel 檔案。
    - 實作了從 Excel (中文表頭) 到 `Student` 模型屬性的欄位對應邏輯。
    - 撰寫了完整的匯入功能測試。

---

## 🔍 問題排查日誌 (Troubleshooting Log)

在開發過程中，我們遇到了一系列問題。詳細記錄如下，以供未來參考。

### 1. Ruby 3.4 的 Gem 相容性問題 (`csv`)

- **錯誤現象**: 執行 `rake` 任務時，出現 `LoadError: cannot load such file -- csv`。
- **根本原因**: `roo` gem 依賴於 `csv` 函式庫。從 Ruby 3.4.0 開始，`csv` 不再是內建的預設 gem，需要手動加入。但 `roo` 的 gemspec 未將其聲明為依賴。
- **解決方案**: 在 `Gemfile` 中明確加入 `gem "csv"`。
- **���� **學���與預防**:
  > **在升級 Ruby 版本時，需���別注意標準函式庫的變更。過去的預設 gem 可能需要手動添加到 `Gemfile`。**

### 2. 過時 Gem 的相容性問題 (`axlsx`)

- **錯誤現象**: 執行 `rake` 任務時，出現 `ArgumentError: unknown regexp option: n`。
- **根本原因**: `axlsx` gem 長期未更新 (最後更新於 2018 年)，其內部使用的正規表示式語法與 Ruby 3.4 不相容。
- **解決方案**: 透過網路搜尋，發現社群維護的 `caxlsx` 是其現代化的直接替代品。在 `Gemfile` 中將 `axlsx` 替換為 `caxlsx`。
- **📝 **學習與預防**:
  > **當遇到 Gem 與新版語言不相容的錯誤時，應優先檢查該 Gem 是否仍在積極維護。尋找社群維護的 fork 或替代方案通常是最佳解法。**

### 3. ActiveRecord 關聯未完整定義

- **錯誤現象**: 測試中出現 `NoMethodError: undefined method 'students' for an instance of School`。
- **根本原因**: 在 `Student` 模型中定義了 `belongs_to :school`，但在 `School` 模型中忘記定義對應的 `has_many :students`。
- **解決方案**: 在 `app/models/school.rb` 中加入 `has_many :students, dependent: :destroy`。
- **📝 **學習與預防**:
  > **ActiveRecord 的關聯是雙向的。定義 `belongs_to` 後，務必在另一個模型中定義 `has_many` 或 `has_one`，以確保雙向關聯的完整性。**

### 4. Ruby 語法錯誤：動態常數賦值

- **錯誤現象**: 所有測試均失敗，並顯示 `SyntaxError: dynamic constant assignment`。
- **根本原因**: 將 `COLUMN_MAPPING` 這個常數（大寫字母開頭）定義在了 `import` 方法內部。在 Ruby 中，常數必須在 Class 或 Module 的頂層定義。
- **解決方案**: 將 `COLUMN_MAPPING` 的定義移出 `import` 方法，直接放在 `Api::StudentsController` Class 的頂層。
- **📝 **學習與預防**:
  > **嚴格遵守 Ruby 的語法規則。常數（Constant）具有靜態的 Class/Module 級別作用域，絕不能在方法內部進行定義。**

### 5. 測試資料狀態污染

- **錯誤現象**: 匯入測試失敗，除錯訊息顯示 `Validation errors: Student has already been taken`。
- **根本原因**: 測試 setup (`let!`) 中預先建立的學生資料，其 `student_id` 與��試匯入的 Excel 檔案中的 `student_id` 重複，觸發了模型的唯一���驗證 (`uniqueness`)。
- **解決方案**: 修改匯入功能的測試，讓它在一個全新的、沒有任何學生資料的 `school_for_import` 物件上進行，從而隔離了測試狀態。
- **📝 **學習與預防**:
  > **測試之間應保持獨立，避免狀態污染。在測試「建立」或「匯入」這類功能時，要確保測試的初始狀態是乾淨、可預測的，不會與待建立的資料產生衝突。**

---

## 結語

這次開發雖然波折不斷，但也讓我們對新版 Ruby on Rails 的特性、Gem 的依賴管理以及測試的嚴謹性有了更深刻的理解。上述記錄的問題與解決方案，將成為我們專案寶貴的知識資產。

---
---

# 開發日誌 (2025-07-08)

**主題：社團資料管理功能 - CRUD 及 Excel 匯入**

## ✅ 工作成果

延續學生資料管理的成功經驗，我們順利地完成了社團資料管理的全部功能。

1.  **模型與多租戶**:
    - 建立了 `Club` 模型，包含規格書中定義的所有欄位，並設定了相應的 `validates` 驗���規則。
    - 在 `School` 模型中加入了 `has_many :clubs` 關聯。
    - `Club` 模型同樣受到 `acts_as_tenant` 的管理，資料被正確地隔離在各個學校之下。

2.  **CRUD API**:
    - 實作了 `/api/schools/:school_id/clubs` 的 `index`, `create`, `update`, `destroy` 四個端點。
    - 撰寫了完整的請求測試，確保 API 功能正常且符合多租戶的預期。

3.  **Excel 匯入功能**:
    - 擴充了 `test:generate_fixtures` Rake 任務，使其也能產生社團的測試 Excel 檔案。
    - 在 `Api::ClubsController` 中實作了 `import` 動作，包含了從中文表頭到模型屬性的對應邏輯。
    - 撰寫了匯入功能的測試，並順利通過。

## 🔍 問題排查日誌

本次開發過程非常順利，沒有遇到新的重大問題。先前在學生資料管理開發中獲得的經驗（特別是關於 Gem 相容性、`acts_as_tenant` 的使用和測試資料隔離）讓我們得以避開了許多潛在的陷阱。

---
---

# 開發日誌 (2025-07-08)

**主題：系統設定功能**

## ✅ 工作成果

完成了讓學校管理員設定其學校專屬參數的功能��

1.  **模型與關聯**:
    - 根據需求，建立了 `SchoolSetting` 模型，包含 `welcome_message` 及四個 `datetime` 型別的活動時間欄位。
    - 建立了 `School` 與 `SchoolSetting` 之間的一對一 (`has_one`/`belongs_to`) 關聯，並加入了唯一性驗證確保資料完整性。

2.  **API 設計**:
    - 採用單數資源 (`resource`) 路由，設計了 `GET /api/schools/:school_id/setting` 及 `POST/PATCH` 端點。
    - 在 `Api::SchoolSettingsController` 中，實作了「尋找或建立/更新」的邏輯，讓前端可以用同一個端點來初始化或更新設定，簡化了介面操作。

3.  **測試**:
    - 撰寫了完整的請求測試，涵蓋了設定不存在和已存在兩種情境下的讀取、建立和更新操作，確保 API 的穩健性。
