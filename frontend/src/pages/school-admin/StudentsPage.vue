<template>
  <div class="p-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-900">學生管理</h1>
      <div class="flex space-x-4">
        <button
          @click="navigateTo('/school-admin/students/import')"
          class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
        >
          批次匯入
        </button>
        <button
          @click="showAddStudentModal = true"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          新增學生
        </button>
        <button
          @click="refreshData"
          :disabled="isLoading"
          class="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 disabled:opacity-50"
        >
          {{ isLoading ? '載入中...' : '重新整理' }}
        </button>
      </div>
    </div>

    <!-- 搜尋與篩選 -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">搜尋學生</label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="學號、姓名或身分證字號"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">年級</label>
          <select
            v-model="selectedGrade"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          >
            <option value="">全部年級</option>
            <option value="1">國一</option>
            <option value="2">國二</option>
            <option value="3">國三</option>
            <option value="4">高一</option>
            <option value="5">高二</option>
            <option value="6">高三</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">班級</label>
          <select
            v-model="selectedClass"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          >
            <option value="">全部班級</option>
            <option v-for="cls in availableClasses" :key="cls" :value="cls">
              {{ cls }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">狀態</label>
          <select
            v-model="selectedStatus"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          >
            <option value="">全部狀態</option>
            <option value="active">正常</option>
            <option value="inactive">停用</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 統計卡片 -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-blue-100">
            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">總學生數</p>
            <p class="text-2xl font-bold text-gray-900">{{ filteredStudents.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-green-100">
            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">已選社學生</p>
            <p class="text-2xl font-bold text-gray-900">{{ studentsWithSelection.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-yellow-100">
            <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">未選社學生</p>
            <p class="text-2xl font-bold text-gray-900">{{ studentsWithoutSelection.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-purple-100">
            <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">已分發學生</p>
            <p class="text-2xl font-bold text-gray-900">{{ assignedStudents.length }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 學生列表 -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">學生列表</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">學號</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">姓名</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">年級班級</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">座號</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">選社狀態</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">分發結果</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="student in paginatedStudents" :key="student.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ student.student_number || student.student_id || '無學號' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ student.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ getGradeText(student.grade) }}{{ student.class_name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ student.seat_number }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span 
                  v-if="student.has_selection" 
                  @click="viewStudentSelections(student)"
                  class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800 cursor-pointer hover:bg-green-200 transition-colors"
                >
                  已選社
                </span>
                <span v-else class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                  未選社
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                <span v-if="student.assigned_club" class="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                  {{ student.assigned_club }}
                </span>
                <span v-else class="text-gray-500">未分發</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  @click="viewStudentDetail(student)"
                  class="text-blue-600 hover:text-blue-900 mr-3"
                >
                  查看
                </button>
                <button
                  @click="editStudentDetail(student)"
                  class="text-green-600 hover:text-green-900 mr-3"
                >
                  編輯
                </button>
                <button
                  @click="deleteStudent(student.id, student.name)"
                  class="text-red-600 hover:text-red-900"
                >
                  刪除
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- 分頁 -->
      <div class="px-6 py-4 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700">
            顯示 {{ (currentPage - 1) * pageSize + 1 }} 到 {{ Math.min(currentPage * pageSize, filteredStudents.length) }} 筆，共 {{ filteredStudents.length }} 筆
          </div>
          <div class="flex space-x-2">
            <button
              @click="currentPage--"
              :disabled="currentPage <= 1"
              class="px-3 py-1 text-sm bg-gray-200 rounded disabled:opacity-50 text-gray-800"
            >
              上一頁
            </button>
            <button
              @click="currentPage++"
              :disabled="currentPage >= totalPages"
              class="px-3 py-1 text-sm bg-gray-200 rounded disabled:opacity-50 text-gray-800"
            >
              下一頁
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新增學生對話框 -->
    <div v-if="showAddStudentModal" class="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center p-4">
      <div class="relative bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 transform transition-all">
        <!-- 標題區域 -->
        <div class="bg-gradient-to-r from-blue-600 to-blue-700 rounded-t-xl px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-bold text-white">新增學生</h3>
                <p class="text-blue-100 text-sm">請填寫學生基本資料</p>
              </div>
            </div>
            <button
              @click="showAddStudentModal = false"
              class="text-white hover:text-gray-200 transition-colors"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- 表單內容 -->
        <div class="p-6">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- 基本資料區域 -->
            <div class="space-y-5">
              <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">基本資料</h4>
              
              <!-- 學號輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                  </svg>
                  <span>學號</span>
                </label>
                <input
                  v-model="newStudent.student_id"
                  type="text"
                  placeholder="請輸入學生學號"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>

              <!-- 姓名輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  <span>姓名</span>
                </label>
                <input
                  v-model="newStudent.name"
                  type="text"
                  placeholder="請輸入學生姓名"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>

              <!-- 年級與班級 -->
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                    <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                    <span>年級</span>
                  </label>
                  <select
                    v-model="newStudent.grade"
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                    required
                  >
                    <option value="">選擇年級</option>
                    <option value="1">國一</option>
                    <option value="2">國二</option>
                    <option value="3">國三</option>
                    <option value="4">高一</option>
                    <option value="5">高二</option>
                    <option value="6">高三</option>
                  </select>
                </div>
                <div class="space-y-2">
                  <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                    <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                    <span>班級</span>
                  </label>
                  <input
                    v-model="newStudent.class_name"
                    type="text"
                    placeholder="例: 忠"
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                    required
                  />
                </div>
              </div>

              <!-- 座號輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14" />
                  </svg>
                  <span>座號</span>
                </label>
                <input
                  v-model="newStudent.seat_number"
                  type="number"
                  placeholder="請輸入座號"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>

              <!-- 身分證字號輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2" />
                  </svg>
                  <span>身分證字號</span>
                </label>
                <input
                  v-model="newStudent.id_number"
                  type="text"
                  placeholder="請輸入身分證字號"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>
            </div>

            <!-- 進階資料區域 -->
            <div class="space-y-5">
              <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">進階資料</h4>
              
              <!-- 條件一 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                  </svg>
                  <span>條件一</span>
                </label>
                <input
                  v-model="newStudent.condition1"
                  type="number"
                  placeholder="請輸入條件一（預設：0）"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                />
              </div>

              <!-- 條件二 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                  </svg>
                  <span>條件二</span>
                </label>
                <input
                  v-model="newStudent.condition2"
                  type="number"
                  placeholder="請輸入條件二（預設：0）"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                />
              </div>

              <!-- 條件三 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                  </svg>
                  <span>條件三</span>
                </label>
                <input
                  v-model="newStudent.condition3"
                  type="number"
                  placeholder="請輸入條件三（預設：0）"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 transition-all"
                />
              </div>

              <!-- 說明文字 -->
              <div class="bg-gray-50 rounded-lg p-4">
                <div class="flex items-start space-x-3">
                  <svg class="w-5 h-5 text-blue-500 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <div>
                    <h5 class="text-sm font-medium text-gray-900">進階資料說明</h5>
                    <p class="text-xs text-gray-600 mt-1">
                      條件一、二、三為選社時的特殊條件設定，<br>
                      例如：性別限制、年級限制等，預設值為 0
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 底部按鈕 -->
        <div class="bg-gray-50 rounded-b-xl px-6 py-4">
          <div class="flex justify-end space-x-3">
            <button
              @click="showAddStudentModal = false"
              class="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
            >
              取消
            </button>
            <button
              @click="addStudent"
              :disabled="isLoading"
              class="px-5 py-2.5 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center space-x-2"
            >
              <svg v-if="isLoading" class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              <span>{{ isLoading ? '新增中...' : '新增學生' }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 查看學生詳情對話框 -->
    <div v-if="showViewStudentModal" class="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center">
      <div class="relative bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 transform transition-all">
        <div v-if="selectedStudent" class="relative">
          <!-- 標題區域 -->
          <div class="bg-gradient-to-r from-blue-600 to-blue-700 rounded-t-xl px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <div>
                  <h3 class="text-xl font-bold text-white">{{ selectedStudent.name }}</h3>
                  <p class="text-blue-100 text-sm">學號：{{ selectedStudent.student_number || selectedStudent.student_id || '無學號' }}</p>
                </div>
              </div>
              <button
                @click="showViewStudentModal = false"
                class="text-white hover:text-gray-200 transition-colors"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>

          <!-- 內容區域 -->
          <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- 基本資料 -->
              <div class="space-y-4">
                <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">基本資料</h4>
                
                <div class="bg-gray-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3 mb-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm text-gray-600">年級班級</p>
                      <p class="font-medium text-gray-900">{{ getGradeText(selectedStudent.grade) }} {{ selectedStudent.class_name }}班</p>
                    </div>
                  </div>
                  
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm text-gray-600">座號</p>
                      <p class="font-medium text-gray-900">{{ selectedStudent.seat_number }} 號</p>
                    </div>
                  </div>
                </div>

                <div class="bg-gray-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm text-gray-600">身分證字號</p>
                      <p class="font-medium text-gray-900 font-mono">{{ selectedStudent.id_number }}</p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 選社狀態 -->
              <div class="space-y-4">
                <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">選社狀態</h4>
                
                <div class="bg-gray-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3 mb-4">
                    <div class="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                      </svg>
                    </div>
                    <div class="flex-1">
                      <p class="text-sm text-gray-600">選社狀態</p>
                      <div class="mt-1">
                        <span v-if="selectedStudent.has_selection" class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                          </svg>
                          已選社
                        </span>
                        <span v-else class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                          </svg>
                          未選社
                        </span>
                      </div>
                    </div>
                  </div>
                  
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                      </svg>
                    </div>
                    <div class="flex-1">
                      <p class="text-sm text-gray-600">分發結果</p>
                      <div class="mt-1">
                        <span v-if="selectedStudent.assigned_club" class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          {{ selectedStudent.assigned_club }}
                        </span>
                        <span v-else class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-600">
                          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          未分發
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- 進階資料 -->
                <div class="bg-gray-50 rounded-lg p-4">
                  <h5 class="text-sm font-medium text-gray-900 mb-3">進階資料</h5>
                  <div class="grid grid-cols-3 gap-4">
                    <div class="text-center">
                      <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-2">
                        <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                        </svg>
                      </div>
                      <p class="text-xs text-gray-600">條件一</p>
                      <p class="text-lg font-bold text-gray-900">{{ selectedStudent.condition1 || 0 }}</p>
                    </div>
                    <div class="text-center">
                      <div class="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-2">
                        <svg class="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                        </svg>
                      </div>
                      <p class="text-xs text-gray-600">條件二</p>
                      <p class="text-lg font-bold text-gray-900">{{ selectedStudent.condition2 || 0 }}</p>
                    </div>
                    <div class="text-center">
                      <div class="w-8 h-8 bg-pink-100 rounded-full flex items-center justify-center mx-auto mb-2">
                        <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                        </svg>
                      </div>
                      <p class="text-xs text-gray-600">條件三</p>
                      <p class="text-lg font-bold text-gray-900">{{ selectedStudent.condition3 || 0 }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 底部按鈕 -->
          <div class="bg-gray-50 rounded-b-xl px-6 py-4">
            <div class="flex justify-end space-x-3">
              <button
                @click="showViewStudentModal = false"
                class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
              >
                關閉
              </button>
              <button
                @click="editStudentDetail(selectedStudent); showViewStudentModal = false"
                class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
              >
                編輯學生
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 編輯學生對話框 -->
    <div v-if="showEditStudentModal" class="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center p-4">
      <div class="relative bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 transform transition-all">
        <!-- 標題區域 -->
        <div class="bg-gradient-to-r from-green-600 to-green-700 rounded-t-xl px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-bold text-white">編輯學生</h3>
                <p class="text-green-100 text-sm">修改學生基本資料</p>
              </div>
            </div>
            <button
              @click="showEditStudentModal = false"
              class="text-white hover:text-gray-200 transition-colors"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- 表單內容 -->
        <div class="p-6">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- 基本資料區域 -->
            <div class="space-y-5">
              <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">基本資料</h4>
              
              <!-- 學號輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                  </svg>
                  <span>學號</span>
                </label>
                <input
                  v-model="editStudent.student_id"
                  type="text"
                  placeholder="請輸入學生學號"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>

              <!-- 姓名輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  <span>姓名</span>
                </label>
                <input
                  v-model="editStudent.name"
                  type="text"
                  placeholder="請輸入學生姓名"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>

              <!-- 年級與班級 -->
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                    <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                    <span>年級</span>
                  </label>
                  <select
                    v-model="editStudent.grade"
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                    required
                  >
                    <option value="">選擇年級</option>
                    <option value="1">國一</option>
                    <option value="2">國二</option>
                    <option value="3">國三</option>
                    <option value="4">高一</option>
                    <option value="5">高二</option>
                    <option value="6">高三</option>
                  </select>
                </div>
                <div class="space-y-2">
                  <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                    <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                    <span>班級</span>
                  </label>
                  <input
                    v-model="editStudent.class_name"
                    type="text"
                    placeholder="例: 忠"
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                    required
                  />
                </div>
              </div>

              <!-- 座號輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14" />
                  </svg>
                  <span>座號</span>
                </label>
                <input
                  v-model="editStudent.seat_number"
                  type="number"
                  placeholder="請輸入座號"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>

              <!-- 身分證字號輸入 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2" />
                  </svg>
                  <span>身分證字號</span>
                </label>
                <input
                  v-model="editStudent.id_number"
                  type="text"
                  placeholder="請輸入身分證字號"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                  required
                />
              </div>
            </div>

            <!-- 進階資料區域 -->
            <div class="space-y-5">
              <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">進階資料</h4>
              
              <!-- 條件一 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                  </svg>
                  <span>條件一</span>
                </label>
                <input
                  v-model="editStudent.condition1"
                  type="number"
                  placeholder="請輸入條件一（預設：0）"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                />
              </div>

              <!-- 條件二 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                  </svg>
                  <span>條件二</span>
                </label>
                <input
                  v-model="editStudent.condition2"
                  type="number"
                  placeholder="請輸入條件二（預設：0）"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                />
              </div>

              <!-- 條件三 -->
              <div class="space-y-2">
                <label class="flex items-center space-x-2 text-sm font-medium text-gray-700">
                  <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4" />
                  </svg>
                  <span>條件三</span>
                </label>
                <input
                  v-model="editStudent.condition3"
                  type="number"
                  placeholder="請輸入條件三（預設：0）"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent text-gray-800 transition-all"
                />
              </div>

              <!-- 說明文字 -->
              <div class="bg-gray-50 rounded-lg p-4">
                <div class="flex items-start space-x-3">
                  <svg class="w-5 h-5 text-blue-500 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <div>
                    <h5 class="text-sm font-medium text-gray-900">進階資料說明</h5>
                    <p class="text-xs text-gray-600 mt-1">
                      條件一、二、三為選社時的特殊條件設定，<br>
                      例如：性別限制、年級限制等，預設值為 0
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 底部按鈕 -->
        <div class="bg-gray-50 rounded-b-xl px-6 py-4">
          <div class="flex justify-end space-x-3">
            <button
              @click="showEditStudentModal = false"
              class="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors"
            >
              取消
            </button>
            <button
              @click="updateStudent"
              :disabled="isLoading"
              class="px-5 py-2.5 text-sm font-medium text-white bg-green-600 rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center space-x-2"
            >
              <svg v-if="isLoading" class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              <span>{{ isLoading ? '更新中...' : '更新學生' }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 學生選社內容對話框 -->
    <div v-if="showStudentSelectionsModal" class="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center">
      <div class="relative bg-white rounded-xl shadow-2xl max-w-4xl w-full mx-4 transform transition-all">
        <div v-if="selectedStudent" class="relative">
          <!-- 標題區域 -->
          <div class="bg-gradient-to-r from-green-600 to-green-700 rounded-t-xl px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                  </svg>
                </div>
                <div>
                  <h3 class="text-xl font-bold text-white">{{ selectedStudent.name }} 的選社內容</h3>
                  <p class="text-green-100 text-sm">學號：{{ selectedStudent.student_number || selectedStudent.student_id || '無學號' }}</p>
                </div>
              </div>
              <button
                @click="showStudentSelectionsModal = false"
                class="text-white hover:text-gray-200 transition-colors"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>

          <!-- 內容區域 -->
          <div class="p-6">
            <div v-if="loadingSelections" class="flex justify-center items-center py-8">
              <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
            </div>

            <div v-else-if="selectionsError" class="text-center py-8">
              <div class="text-red-600 mb-4">
                <svg class="w-12 h-12 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="text-lg font-medium">載入選社資料失敗</p>
                <p class="text-sm text-gray-600 mt-1">{{ selectionsError }}</p>
              </div>
              <button
                @click="loadStudentSelections(selectedStudent.id)"
                class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
              >
                重新載入
              </button>
            </div>

            <div v-else>
              <!-- 選社志願列表 -->
              <div v-if="studentSelections.length > 0">
                <h4 class="text-lg font-semibold text-gray-900 mb-4">選社志願列表</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                  <div 
                    v-for="(selection, index) in studentSelections" 
                    :key="selection.id"
                    class="border border-gray-200 rounded-lg p-3 hover:shadow-md transition-shadow bg-white"
                  >
                    <div class="flex items-center space-x-3">
                      <div class="flex items-center justify-center w-8 h-8 bg-blue-100 text-blue-600 rounded-full font-bold text-sm">
                        {{ selection.preference }}
                      </div>
                      <div class="flex-1 min-w-0">
                        <h5 class="font-medium text-gray-900 truncate">{{ selection.club_name }}</h5>
                        <p class="text-xs text-gray-500">編號：{{ selection.club_id }}</p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 選社統計 -->
                <div class="mt-4 bg-gray-50 rounded-lg p-3">
                  <div class="flex items-center justify-between text-sm">
                    <span class="text-gray-600">共填寫 <span class="font-medium text-blue-600">{{ studentSelections.length }}</span> 個志願</span>
                    <span class="text-gray-500">首次選社：{{ formatDateTime(studentSelections[0]?.created_at, 'date') }}</span>
                  </div>
                </div>
              </div>

              <!-- 無選社記錄 -->
              <div v-else class="text-center py-8">
                <svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
                </svg>
                <p class="text-lg font-medium text-gray-900">尚無選社記錄</p>
                <p class="text-sm text-gray-600 mt-1">該學生尚未填寫選社志願</p>
              </div>
            </div>
          </div>

          <!-- 底部按鈕 -->
          <div class="bg-gray-50 rounded-b-xl px-6 py-4">
            <div class="flex justify-end">
              <button
                @click="showStudentSelectionsModal = false"
                class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors"
              >
                關閉
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useStudentStore } from '@/stores/student'
import { useAuthStore } from '@/stores/auth'
import type { Student } from '@/types/student'
import axios from 'axios'
import dayjs from 'dayjs'

const router = useRouter()
const route = useRoute()
const studentStore = useStudentStore()
const authStore = useAuthStore()

// 從路由獲取學校 ID
const schoolId = computed(() => parseInt(route.params.schoolId as string))

// 響應式狀態
const students = ref<Student[]>([])
const searchQuery = ref('')
const selectedGrade = ref('')
const selectedClass = ref('')
const selectedStatus = ref('')
const showAddStudentModal = ref(false)
const showViewStudentModal = ref(false)
const showEditStudentModal = ref(false)
const showStudentSelectionsModal = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const selectedStudent = ref<Student | null>(null)

// 學生選社相關狀態
const studentSelections = ref<any[]>([])
const loadingSelections = ref(false)
const selectionsError = ref('')

// 新增學生表單
const newStudent = ref({
  student_id: '',
  name: '',
  grade: '',
  class_name: '',
  seat_number: '',
  id_number: '',
  condition1: '0',
  condition2: '0',
  condition3: '0'
})

// 編輯學生表單
const editStudent = ref({
  student_id: '',
  name: '',
  grade: '',
  class_name: '',
  seat_number: '',
  id_number: '',
  condition1: '0',
  condition2: '0',
  condition3: '0'
})

// 計算屬性
const isLoading = computed(() => studentStore.isLoading)

const filteredStudents = computed(() => {
  if (!students.value || !Array.isArray(students.value)) return []
  
  let filtered = students.value

  // 搜尋篩選
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(student => 
      (student.student_number || (student as any).student_id || '').toLowerCase().includes(query) ||
      student.name.toLowerCase().includes(query) ||
      student.id_number.toLowerCase().includes(query)
    )
  }

  // 年級篩選
  if (selectedGrade.value) {
    filtered = filtered.filter(student => student.grade === parseInt(selectedGrade.value))
  }

  // 班級篩選
  if (selectedClass.value) {
    filtered = filtered.filter(student => student.class_name === selectedClass.value)
  }

  return filtered
})

const paginatedStudents = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredStudents.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredStudents.value.length / pageSize.value)
})

const availableClasses = computed(() => {
  if (!students.value || !Array.isArray(students.value)) return []
  const classes = [...new Set(students.value.map(s => s.class_name))]
  return classes.sort()
})

const studentsWithSelection = computed(() => {
  if (!students.value || !Array.isArray(students.value)) return []
  return students.value.filter(student => student.has_selection)
})

const studentsWithoutSelection = computed(() => {
  if (!students.value || !Array.isArray(students.value)) return []
  return students.value.filter(student => !student.has_selection)
})

const assignedStudents = computed(() => {
  if (!students.value || !Array.isArray(students.value)) return []
  return students.value.filter(student => student.assigned_club)
})

// 方法
const refreshData = async () => {
  if (!schoolId.value) return

  try {
    await studentStore.fetchStudents(schoolId.value)
    // 從 store 獲取學生資料
    students.value = studentStore.students
    console.log('載入的學生資料:', students.value)
    if (students.value.length > 0) {
      console.log('第一個學生的資料結構:', students.value[0])
    }
  } catch (error) {
    console.error('載入學生資料失敗:', error)
  }
}

const addStudent = async () => {
  if (!schoolId.value) return

  try {
    await studentStore.createStudent(schoolId.value, {
      student_number: newStudent.value.student_id,
      name: newStudent.value.name,
      grade: parseInt(newStudent.value.grade),
      class_name: newStudent.value.class_name,
      seat_number: parseInt(newStudent.value.seat_number),
      id_number: newStudent.value.id_number,
      class_number: 1, // 這裡可能需要根據班級名稱計算
      condition1: parseInt(newStudent.value.condition1) || 0,
      condition2: parseInt(newStudent.value.condition2) || 0,
      condition3: parseInt(newStudent.value.condition3) || 0
    })
    
    showAddStudentModal.value = false
    resetNewStudentForm()
    await refreshData()
    alert('學生新增成功')
  } catch (error) {
    console.error('新增學生失敗:', error)
    alert('新增失敗，請稍後再試')
  }
}

const viewStudentDetail = (student: Student) => {
  selectedStudent.value = student
  showViewStudentModal.value = true
}

const editStudentDetail = (student: Student) => {
  selectedStudent.value = student
  console.log('編輯學生:', student)
  // 複製學生資料到編輯表單
  editStudent.value = {
    student_id: student.student_number || (student as any).student_id || '',
    name: student.name,
    grade: student.grade.toString(),
    class_name: student.class_name,
    seat_number: student.seat_number.toString(),
    id_number: student.id_number,
    condition1: (student.condition1 || 0).toString(),
    condition2: (student.condition2 || 0).toString(),
    condition3: (student.condition3 || 0).toString()
  }
  showEditStudentModal.value = true
}

const updateStudent = async () => {
  if (!schoolId.value || !selectedStudent.value) return

  try {
    const studentId = selectedStudent.value.id
    console.log('更新學生 ID:', studentId, '類型:', typeof studentId)
    
    await studentStore.updateStudent(schoolId.value, studentId, {
      student_number: editStudent.value.student_id,
      name: editStudent.value.name,
      grade: parseInt(editStudent.value.grade),
      class_name: editStudent.value.class_name,
      seat_number: parseInt(editStudent.value.seat_number),
      id_number: editStudent.value.id_number,
      class_number: 1, // 這裡可能需要根據班級名稱計算
      condition1: parseInt(editStudent.value.condition1) || 0,
      condition2: parseInt(editStudent.value.condition2) || 0,
      condition3: parseInt(editStudent.value.condition3) || 0
    })
    
    showEditStudentModal.value = false
    resetEditStudentForm()
    await refreshData()
    alert('學生資料更新成功')
  } catch (error) {
    console.error('更新學生資料失敗:', error)
    alert('更新失敗，請稍後再試')
  }
}

const deleteStudent = async (studentId: number, studentName: string) => {
  if (!confirm(`確定要刪除學生「${studentName}」嗎？\n\n此操作無法復原，學生的所有相關資料都將被刪除。`)) return

  try {
    await studentStore.deleteStudent(schoolId.value, studentId)
    await refreshData()
    alert(`學生「${studentName}」已成功刪除`)
  } catch (error) {
    console.error('刪除學生失敗:', error)
    const errorMessage = error instanceof Error ? error.message : '未知錯誤'
    alert(`刪除失敗：${errorMessage}\n\n請稍後再試，或聯絡系統管理員`)
  }
}

const resetNewStudentForm = () => {
  newStudent.value = {
    student_id: '',
    name: '',
    grade: '',
    class_name: '',
    seat_number: '',
    id_number: '',
    condition1: '0',
    condition2: '0',
    condition3: '0'
  }
}

const resetEditStudentForm = () => {
  editStudent.value = {
    student_id: '',
    name: '',
    grade: '',
    class_name: '',
    seat_number: '',
    id_number: '',
    condition1: '0',
    condition2: '0',
    condition3: '0'
  }
}

const navigateTo = (path: string) => {
  if (!schoolId.value) return
  
  // 構建完整路徑，包含學校 ID
  const fullPath = `/schools/${schoolId.value}/admin${path.replace('/school-admin', '')}`
  router.push(fullPath)
}

const getGradeText = (grade: number) => {
  const gradeMap: { [key: number]: string } = {
    1: '國一',
    2: '國二',
    3: '國三',
    4: '高一',
    5: '高二',
    6: '高三'
  }
  return gradeMap[grade] || `${grade}年級`
}

// 查看學生選社內容
const viewStudentSelections = async (student: Student) => {
  selectedStudent.value = student
  showStudentSelectionsModal.value = true
  await loadStudentSelections(student.id)
}

// 載入學生選社記錄
const loadStudentSelections = async (studentId: number) => {
  if (!schoolId.value || !studentId) return

  try {
    loadingSelections.value = true
    selectionsError.value = ''
    
    // 使用 club_selections API 獲取學生選社記錄
    const response = await axios.get(`/api/schools/${schoolId.value}/club_selections?student_id=${studentId}`, {
      headers: {
        'Authorization': `Bearer ${authStore.token}`
      }
    })
    
    studentSelections.value = response.data.sort((a: any, b: any) => a.preference - b.preference)
    
  } catch (error: any) {
    console.error('載入學生選社記錄失敗:', error)
    selectionsError.value = error.response?.data?.error || '載入失敗'
  } finally {
    loadingSelections.value = false
  }
}

// 格式化日期時間
const formatDateTime = (dateTime: string, format: 'datetime' | 'date' = 'datetime') => {
  if (!dateTime) return ''
  
  const date = dayjs(dateTime)
  if (format === 'date') {
    return date.format('YYYY/MM/DD')
  }
  return date.format('YYYY/MM/DD HH:mm')
}


// 生命週期
onMounted(() => {
  refreshData()
})
</script>