# 指定入社 頁面設計
File: frontend/src/pages/school-admin/AssignmentsPage.vue


本頁面有兩個主要功能：

特殊身份學生優先指定入社。
顯示所有特殊身份學生，以及他們被指定的社團。



## 步驟一：
先為特殊身份學生增加一個辨識欄位 special：特殊學生。
此欄位建議使用整數值，預設值為 0，表示非特殊身份學生。
特殊身份學生可以是 1（老師指定）
並在未來保留其他數字作為其他特殊身份的標記（擴充性）。
現在只需要實作 0 與 1 的情況。


## 步驟二：
在 AssignmentsPage.vue 頁面下方顯示所有特殊身份學生，並提供一個撤銷功能，可以取消他們的特殊身份。
亦即顯示 student.special = 1 的學生列表。
撤銷功能是將 student.special 變更為 0。


## 步驟三：
頁面上方提供搜尋社團的功能，使用者可以輸入社團名稱或編號來搜尋。
找到社團後，點擊可以列出該社的特殊學生名單。
並且可以新增。新增的方式是輸入學生的學號或姓名，會列出符合的人選可能有數人（比如同名）
在旁邊可以點擊此學生加入此社。

加入的方法是變更該位學生的特殊狀態（從0變成1）。
並且在 club_selections 表中新增一筆資料，記錄學生的student_id、社團club_id、school_id、preference=1。

API: 設計一個新的指定入社的 API 接口。
app/controllers/api/club_selections_controller.rb
請注意此檔案內的變數名稱，務必對應。
且須使用留意增加安全性規則，只有「該校的 school_admin」 或者 「super_admin」 才能存取。

t.integer "student_id", null: false
t.integer "club_id", null: false
t.integer "school_id", null: false
t.integer "preference", null: false


## 步驟四：
修改學生的登入跳轉頁面。
frontend/src/pages/student/LoginPage.vue
redirectAfterLogin()
在登入後，若學生有特殊身份（student.special = 1），
則顯示他們已經被指定到某個社團，並且無需（不可）再進行選社。


# 已完成功能：

  1. 為學生模型增加 special 欄位：
    - 添加了資料庫遷移檔案，預設值為 0
    - 更新了 Student 模型的驗證規則
  2. 設計指定入社 API 接口：
    - 創建了 StudentPolicy 進行權限控制
    - 在 club_selections_controller.rb 中添加了 4 個新的 API 端點：
        - assign_student - 指定學生入社
      - revoke_special_status - 撤銷特殊身份
      - special_students - 獲取特殊身份學生列表
      - search_students - 搜尋學生
    - 使用 Pundit 和 acts_as_tenant 確保安全性
  3. 實作 AssignmentsPage.vue 前端頁面：
    - 搜尋社團功能
    - 搜尋學生功能
    - 指定學生入社功能
    - 特殊身份學生列表顯示
    - 撤銷特殊身份功能
  4. 修改學生登入跳轉邏輯：
    - 更新了 User 和 Student 型別定義
    - 修改了 auth store 來包含 special 欄位
    - 更新了 redirectAfterLogin 函數，讓特殊身份學生直接導向結果頁面

  🔒 安全性保護：
  - 使用 acts_as_tenant 確保跨校資料隔離
  - 使用 Pundit 進行精細的權限控制
  - 甲學校管理員無法操作乙學校的學生

  指定入社功能現在已經完整實作，管理員可以透過 AssignmentsPage
  來管理特殊身份學生，而特殊身份學生登入後會直接看到被指定的社團資訊。