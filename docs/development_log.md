# 開發日誌 (2025-07-09)

**主題：選情報導功能 - 熱門社團回報**

## 🎯 本次目標

建立一個 API 端點，用於回報各個社團被學生選為「第一志願」的人數，作為判斷社團熱門程度的依據。

## ✅ 工作成果

1.  **API 端點與路由**:
    - 在 `clubs` 資源下，新增了一個集合路由 `hotness_report`。
    - 建立了新的 API 端點 `GET /api/schools/:school_id/clubs/hotness_report`。

2.  **Controller 邏輯實作**:
    - 在 `Api::ClubsController` 中新增了 `hotness_report` 動作。
    - 該動作使用 `left_joins` 和 `group` 執行了一次高效的資料庫查詢，計算出每個社團的第一志願數量。
    - 查詢結果會為每個社團物件附加一個 `first_choice_count` 屬性，即使某個社團沒有人選為第一志願，其計數也會正確地顯示為 0。

3.  **模型關聯補齊**:
    - 在開發過程中，我們發現 `School` 模型缺少了 `has_many :club_selections` 的關聯，這導致在測試中無法正確建立屬於特定學校的 `ClubSelection` 記錄。我們及時補上了這個關聯。

4.  **完整的測試**:
    - 在 `spec/requests/api/clubs_spec.rb` 中，為 `hotness_report` 端點撰寫了完整的請求測試。
    - 測試涵蓋了多個社團和多個學生，並驗證了回傳的 JSON 結果中，每個社團的第一志願計數是否與預期完全相符。

## 🔍 問題排查日誌

- **錯誤現象**: 測試執行時，出現 `ActiveRecord::RecordInvalid: Validation failed: School must exist`。
- **根本原因**: 這是由 `acts_as_tenant` 的多租戶驗證所引發的。在測試環境中建立 `ClubSelection` 記錄時，我們忘記將其與當前的 `school` (租戶) 進行關聯。
- **解決方案與演進**:
    1.  **初次嘗試**: 我們試圖使用 `school.club_selections.create!` 來建立記錄，但這引發了第二個錯誤。
    2.  **第二次錯誤**: `NoMethodError: undefined method 'club_selections' for an instance of School`。這個錯誤讓我們意識到，我們從未在 `School` 模型中定義 `has_many :club_selections` 這個關聯。
    3.  **最終解決方案**: 我們採取了雙重修正：
        -   ��先，在 `app/models/school.rb` 中補上 `has_many :club_selections, dependent: :destroy`。
        -   然後，修正測試程式碼，使用 `ClubSelection.create!(school: school, ...)` 的方式來建立測試資料。這樣既能通過 `acts_as_tenant` 的驗證，也符合 ActiveRecord 的標準實踐。

- **📝 **學習與預防**:
  > **在多租戶環境下進行測試時，必須時刻注意租戶的關聯性。所有屬於租戶的模型（如 `ClubSelection`）在建立時，都必須明確地與一個租戶實例（如 `school`）關聯。同時，要確保所有 `has_many` 和 `belongs_to` 的關聯都已完整定義，這是保證測試程式碼可讀性和功能正確性的基礎。**

## 結語

本次開發順利完成了選情報導的第一個核心功能。解決測試中關於多租戶的關聯問題，加深了我們對 `acts_as_tenant` 在測試環境中運作方式的理解。這個 API 為前端呈現熱門社團提供了關鍵的數據支持。

---
---
# 開發日誌 (2025-07-09)

**主題：學生選社功能實作**

## 🎯 本次目標

建立一個讓學生能夠提交社團志願的機制，並將選擇結果儲存於資料庫。

## ✅ 工作成果

1.  **資料庫與模型設計**:
    - 經過討論，我們決定採用包含 `preference` (志願序) 欄位的設計，以確保資料的明確性、查詢效率和未來擴充性。
    - 建立了 `ClubSelection` 模型與對應的資料表，包含 `student_id`, `club_id`, `school_id`, `preference` 欄位。
    - 在資料庫層級加入了唯一性索引 (`[student_id, club_id]` 和 `[student_id, preference]`)，從根本上保證了資料的完整性。
    - 更新了 `Student` 和 `Club` 模型，加入了 `has_many :club_selections` 關聯，方便日後查詢。

2.  **API 端點實作**:
    - 建立了新的 API 端點 `POST /api/schools/:school_id/club_selections`。
    - 在 `Api::ClubSelectionsController` 中實作了 `create` 動作。此動��會接收一個包含 `student_id` 和 `club_ids` 陣列的請求。
    - 為了確保操作的原子性，整個「先刪除舊志願、再建立新志願」的過程被包裹在一個資料庫事務 (`transaction`) 中。

3.  **認證與多租戶處理**:
    - 由於此端點是給學生使用（未來將採用學號+身分證登入，而非 API Token），我們在 `ClubSelectionsController` 中明確地使用 `skip_before_action` 跳過了 `ApplicationController` 中的 `authenticate_user!` 和 `set_tenant`。
    - 同時，我們建立了一個此控制器專用的 `around_action` (`set_tenant_for_club_selection`)，它只根據 URL 中的 `school_id` 來設定租戶，確保了功能的獨立與安全。

4.  **完整的測試**:
    - 撰寫了完整的 RSpec Request Spec，涵蓋了成功提交、學生或社團不存在、以及參數格式錯誤等多種情境。
    - 測試確保了 API 的行為符合預期，並且能夠正確地處理各種邊界情況。

## 🔍 問題排查日誌

- **錯誤現象**: 測試最初因 `NoMethodError: undefined method 'Authorization'` 而失敗。
- **根本原因**: `rswag` 預設會繼承 `swagger_helper.rb` 中定義的 `security` (Bearer Auth) 要求。但我們的學生選社 API 是公開的（未來有自己的認證機制），不需要 Token。
- **解決方案**: 在 `club_selections_spec.rb` 的 `post` 區塊中，明確地加入 `security []`，覆寫了全域設定，表明此端點不需要安全驗證。

- **錯誤現象**: ���正上述問題後，測試仍然失敗，回應為 `401 Not Authorized`。
- **根本原因**: `ApplicationController` 中的 `before_action :authenticate_user!` 對所有繼承它的控制器都生效，導致即使 `rswag` 不發送 `Authorization` 標頭，後端依然會執行驗證並拒絕請求。
- **解決方案**: 在 `Api::ClubSelectionsController` 中加入了 `skip_before_action :authenticate_user!`，徹底繞過了這個驗證。

## 結語

本次開發成功地完成了學生選社的核心功能。從資料庫設計的權衡取捨，到 API 的實作與測試，再到對認證和多租戶機制的靈活處理，都體現了我們對專案架構的深刻理解。這次的經驗也讓我們更清楚如何在需要時，安全地為特定端點開放不同於全域規則的權限。

---
---
# 開發日誌與問題報告 (2025-07-08)

**主題：學生資料管理功能 - CRUD 及 Excel 匯入**

## 🎯 本次目標

完成學生資料的完整生命週期管理，包括：
1.  建立 `Student` 模型並整合多租戶 (`acts_as_tenant`)。
2.  實作完整的 CRUD (Create, Read, Update, Delete) API。
3.  實作透過 Excel 檔��大量匯入學生資料的功能。
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
    - 實作了從 Excel (中文表頭) 到 `Student` 模型屬性��欄位對應邏輯。
    - 撰寫了完整的匯入功能測試。

---

## 🔍 問題排查日誌 (Troubleshooting Log)

在開發過程中，我們遇到了一系列問題。詳細記錄如下，以供未來參考。

### 1. Ruby 3.4 的 Gem 相容性問題 (`csv`)

- **錯誤現象**: 執行 `rake` 任務時，出現 `LoadError: cannot load such file -- csv`。
- **根本原因**: `roo` gem 依賴於 `csv` 函式庫。從 Ruby 3.4.0 開始，`csv` 不再是內建的預設 gem，需要手動加入。但 `roo` 的 gemspec 未將其聲明為依賴。
- **解決方案**: 在 `Gemfile` 中明確加入 `gem "csv"`。
- **📝 **學習與預防**:
  > **在升級 Ruby 版本時，需特別注意標準函式庫的變更。過去的預設 gem 可能需要手動添加到 `Gemfile`。**

### 2. 過時 Gem 的相容性問題 (`axlsx`)

- **錯誤現象**: 執行 `rake` 任務時，出現 `ArgumentError: unknown regexp option: n`。
- **根本原因**: `axlsx` gem 長期未更新 (最後更新於 2018 年)，其內部使用的正規表示式語法與 Ruby 3.4 不相容。
- **解決方案**: 透過網路搜尋，發現社群維護的 `caxlsx` 是���現代化的直接替代品。在 `Gemfile` 中將 `axlsx` 替換為 `caxlsx`。
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
- **根本原因**: 測試 setup (`let!`) 中預先建立的學生資料，其 `student_id` 與測試匯入的 Excel 檔案中的 `student_id` 重複，觸發了模型的唯一性驗證 (`uniqueness`)。
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
    - 建立了 `Club` 模型，包含規格書中定義的所有欄位，並設定了相應的 `validates` 驗證規則。
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

完成了讓學校管理員設定其學校專屬參數的功能。

1.  **模型與關聯**:
    - 根據需求，建立了 `SchoolSetting` 模型，包含 `welcome_message` 及四個 `datetime` 型別的活動時間欄位。
    - 建立了 `School` 與 `SchoolSetting` 之間的一對一 (`has_one`/`belongs_to`) 關聯，並加入了唯一性驗證確保資料完整性。

2.  **API 設計**:
    - 採用單數資源 (`resource`) 路由，設計了 `GET /api/schools/:school_id/setting` 及 `POST/PATCH` 端點。
    - 在 `Api::SchoolSettingsController` 中，實作了「尋找或建立/更新」的邏輯，讓��端可以用同一個端點來初始化或更新設定，簡化了介面操作。

3.  **測試**:
    - 撰寫了完整的請求測試，涵蓋了設定不存在和已存在兩種情境下的讀取、建立和更新操作，確保 API 的穩健性。

---
---

# 開發日誌 (2025-07-08)

**主題：認證與授權系統**

## 🎯 本次目標

建立一個穩健、有彈性的認證與授權機制，以保護所有 API 端點，並能區分不同角色的權限。

## ✅ 工作成果

1.  **靈活的資料模型**:
    - 摒棄了讓 User 直接屬於 School 的僵硬設計，改為採用 `User` <> `Membership` <> `School` 的多對多關聯模型。這為未來「一人多校」、「一人多角色」等複雜情境打下了堅實的基礎。
    - 在 `User` 模型上增加了全域 `role` 欄位 (`super_admin`, `school_user`)，用於區分全域管理員和一般學校使用者。
    - 在 `Membership` 模型上增加了校內 `role` 欄位 (`admin`, `teacher`)，用於定義使用者在特定學校的職責。

2.  **API Token 認證**:
    - 在 `User` 模型中，實作了在建立使用者時自動產生唯一 `api_token` 的功能。
    - 在 `ApplicationController` 中，建立了 `authenticate_user!` 這個 `before_action`，透過檢查請求標頭中的 `Authorization: Bearer <token>` 來驗證使用者身份。

3.  **雙軌授權機制**:
    - 在 `ApplicationController` 的 `set_tenant` 方法中，實作了雙軌授權邏輯：
      - **超級管理員**: 如果 `@current_user` 是 `super_admin`，則允許其存取 URL 中指定的任何學校。
      - **學校使用者**: 如果是 `school_user`，則只允許其存取自己擁有 `Membership` 的學校。
    - 這個機制完美地解決了「超級管理員如何操作特定學校」的問題，同時保障了一般使用者的資料安全。

4.  **全面的測試更新**:
    - 建立了 `spec/support/api_helpers.rb` 來簡化測試中的使用者和認證標頭的建立。
    - 更新了 **所有** 現存的請求測試 (`request specs`)，為每一個 API 請求���加入了認證標頭，確保了整個系統在新的認證授權機制下依然能正常運作。

## 🔍 問題排查日誌

- **錯誤現象**: 在 `spec/rails_helper.rb` 中，因手誤留下了一個多餘的 `-` 字元，導致所有測試檔案載入失敗，出現 `NoMethodError: undefined method '-@' for nil` 的錯誤。
- **解決方案**: 仔細檢查並修正 `spec/rails_helper.rb` 中的語法錯誤。
- **📝 **學習與預防**:
  > **當出現全局性的、看似無關的載入錯誤時，應優先檢查核心設定檔（如 `rails_helper.rb`）是否有語法問題。**

- **錯誤現象**: 再次出現了 `enum` 語法錯誤 (`ArgumentError`)。
- **解決方案**: 將 `User` 和 `Membership` 模型中的 `enum` 語法從 Rails 7 的 `enum role: { ... }` 修改為 Rails 8 的 `enum :role, { ... }`。
- **📝 **學習與預防**:
  > **犯過的錯也可能會再犯。建立一個團隊共用的「常見錯誤與解決方案」文件（就像我們現在正在做的），可以有效地減少重複犯錯的機率。**

## 結語

本次開發是專案的一個重要轉折點。我們建立了一個專業、可擴充��認證授權系統，為後續所有功能的開發提供了安全保障。雖然過程中有小插曲，但都順利解決，並再次強化了我們對新版 Rails 的掌握。

---
---

# 開發日誌 (2025-07-08)

**主題：API 文件系統整合 (RSwag)**

## 🎯 本次目標

為專案建立一個專業、可互動、且與程式碼同步的 API 文件系統。

## ✅ 工作成果

1.  **整合 RSwag**:
    - 在 `Gemfile` 中成功加入了 `rswag-api`, `rswag-ui`, `rswag-specs`。
    - 完成了 `rswag` 的安裝與設定，包括產生 `swagger_helper.rb` 並定義了 API 的基本資訊、伺服器位置和安全機制 (Bearer Auth)。
    - 在 `routes.rb` 中成功掛載了 `Rswag::Ui` 和 `Rswag::Api` 引擎，讓我們可以透過 `/api-docs` 存取 API 文件。

2.  **文件撰寫**:
    - 將 **所有** 現存的請求測試 (`request specs`) 都轉換為 `rswag` 的文件格式。
    - 為每一個 API 端點都定義了清晰的標籤 (tags)、參數 (parameters)、請求體 (request body) 和可能的回應 (responses)。

3.  **產生文件**:
    - 成功執行 `rake rswag:specs:swaggerize` 指令，產生了完整��� `swagger.yaml` OpenAPI 文件。
    - 我們現在擁有了一個可以隨時啟動 `rails server` 並在 `/api-docs` 瀏覽和測試的互動式 API 文件。

## 🔍 問題排查日誌

- **錯誤現象**: `rswag` 的安裝指令 `rails g rswag:install` 失效。
- **根本原因**: 新版的 `rswag` 將安裝指令分成了三個獨立的指令。
- **解決方案**: 依次執行 `rails g rswag:api:install`, `rails g rswag:ui:install`, `rails g rswag:specs:install`。
- **📝 **學習與預防**:
  > **工具的指令會隨著版本更新而改變。當指令失效時，應查閱官方文件或執行 `rails g --help` 來確認最新的指令用法。**

- **錯誤現象**: 測試執行時出現 `NoMethodError: undefined method 'path' for class ...`。
- **根本原因**: 對 `rswag` 的 DSL 語法理解有誤，錯誤地將 `path` 放在了 `describe` 區塊的內部或外部。
- **解決方案**: 仔細查閱 `rswag` 的文件和範例，確認了正確的語法結構：`describe` 作為最外層，`path` 在其內部，而 `run_test!` 則在 `response` 區塊內。
- **📝 **學習與預防**:
  > **在引入一個新的、複雜��� DSL (領域特定語言) 時，不要想當然耳。花時間閱讀官方文件中的「Hello World」等級範例，是避免反覆試錯、提升效率的最佳途徑。**

- **錯誤現象**: 測試執行時出現 `Rswag::Specs::ConfigurationError: No openapi_specs defined`。
- **根本原因**: 雖然 `swagger_helper.rb` 內容正確，但在某些測試檔案中，它沒有被正確地載入，導致 `rswag` 的設定在執行時是未知的。
- **解決方案**: 在 **所有** 使用 `rswag` 語法的 `_spec.rb` 檔案開頭，將 `require 'rails_helper'` 替換為 `require 'swagger_helper'`，確保 `rswag` 的設定總是被優先載入。
- **📝 **學習與預防**:
  > **RSpec 的載入順序很重要。對於需要特定設定的 gem (如 `rswag`)，確保它的設定輔助檔案 (`swagger_helper.rb`) 在測試檔案中被明確且優先地 `require`，是保證測試環境正確初始化的關鍵。**

## 結語

這次的開發過程再次證明了「工欲善其事，必先利其器」的道理。我們不僅完成了 API 文件系統的建置，更重要的是，我們透過解決設定過程中的種種問題，對 RSpec 的設定和 `rswag` 的運作原理有了更深入的理解。這份可互動的 API 文件將極大地提升我們未來的開發效率和團隊協作的順暢度。
