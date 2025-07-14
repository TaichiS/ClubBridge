<template>
  <div class="p-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-900">社團選擇</h1>
      <div class="flex space-x-4">
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
          <label class="block text-sm font-medium text-gray-700 mb-2">搜尋社團</label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="社團名稱、指導老師或描述"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">類別</label>
          <select
            v-model="selectedCategory"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          >
            <option value="">全部類別</option>
            <option v-for="category in availableCategories" :key="category" :value="category">
              {{ category }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">條件一</label>
          <select
            v-model="selectedCondition1"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          >
            <option value="">全部</option>
            <option value="1">限男生</option>
            <option value="2">限女生</option>
            <option value="0">無限制</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">條件二</label>
          <select
            v-model="selectedCondition2"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
          >
            <option value="">全部</option>
            <option value="1">限高中</option>
            <option value="2">限國中</option>
            <option value="0">無限制</option>
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
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">總社團數</p>
            <p class="text-2xl font-bold text-gray-900">{{ filteredClubs.length }}</p>
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
            <p class="text-sm font-medium text-gray-600">有空位社團</p>
            <p class="text-2xl font-bold text-gray-900">{{ availableClubs.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-red-100">
            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">已滿社團</p>
            <p class="text-2xl font-bold text-gray-900">{{ fullClubs.length }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="p-3 rounded-full bg-purple-100">
            <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">總容量</p>
            <p class="text-2xl font-bold text-gray-900">{{ totalCapacity }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 社團列表 -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">社團列表</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">編號</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">社團名稱</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">類別</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">指導老師</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">人數</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">上課地點</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">狀態</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="club in paginatedClubs" :key="club.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ club.code }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ club.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ club.category }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ club.instructor }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ (club.current_members || 0) }}/{{ club.max_members }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ club.location }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span v-if="(club.current_members || 0) >= club.max_members" class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                  已滿
                </span>
                <span v-else class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                  可選
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <button
                  @click="viewClubDetail(club)"
                  class="text-blue-600 hover:text-blue-900 mr-3"
                >
                  查看
                </button>
                <button
                  @click="editClubDetail(club)"
                  class="text-green-600 hover:text-green-900 mr-3"
                >
                  編輯
                </button>
                <button
                  @click="deleteClub(club.id, club.name)"
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
            顯示 {{ (currentPage - 1) * pageSize + 1 }} 到 {{ Math.min(currentPage * pageSize, filteredClubs.length) }} 筆，共 {{ filteredClubs.length }} 筆
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

    <!-- 新增社團對話框 -->
    <div v-if="showAddClubModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">新增社團</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">社團編號</label>
              <input
                v-model="newClub.code"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">社團名稱</label>
              <input
                v-model="newClub.name"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">類別</label>
              <input
                v-model="newClub.category"
                type="text"
                placeholder="如：體育、藝文、學術"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">指導老師</label>
              <input
                v-model="newClub.instructor"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">最大人數</label>
              <input
                v-model="newClub.max_members"
                type="number"
                min="1"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">上課地點</label>
              <input
                v-model="newClub.location"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">簡介</label>
              <textarea
                v-model="newClub.description"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              ></textarea>
            </div>
          </div>
          <div class="flex justify-end space-x-3 mt-6">
            <button
              @click="showAddClubModal = false"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
            >
              取消
            </button>
            <button
              @click="addClub"
              :disabled="isLoading"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {{ isLoading ? '新增中...' : '新增' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 查看社團詳情對話框 -->
    <div v-if="showViewClubModal" class="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center">
      <div class="relative bg-white rounded-xl shadow-2xl max-w-4xl w-full mx-4 transform transition-all">
        <div v-if="selectedClub" class="relative">
          <!-- 標題區域 -->
          <div class="bg-gradient-to-r from-blue-600 to-blue-700 rounded-t-xl px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                </div>
                <div>
                  <h3 class="text-xl font-bold text-white">{{ selectedClub.name }}</h3>
                  <p class="text-blue-100 text-sm">編號：{{ selectedClub.code }}</p>
                </div>
              </div>
              <button
                @click="showViewClubModal = false"
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
                      <p class="text-sm text-gray-600">類別</p>
                      <p class="font-medium text-gray-900">{{ selectedClub.category }}</p>
                    </div>
                  </div>
                  
                  <div class="flex items-center space-x-3 mb-3">
                    <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm text-gray-600">指導老師</p>
                      <p class="font-medium text-gray-900">{{ selectedClub.instructor }}</p>
                    </div>
                  </div>
                  
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm text-gray-600">上課地點</p>
                      <p class="font-medium text-gray-900">{{ selectedClub.location }}</p>
                    </div>
                  </div>
                  
                  <div v-if="selectedClub.rainy_location" class="flex items-center space-x-3 mt-3">
                    <div class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0016.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 002 8.5c0 2.29 1.51 4.04 3 5.5l7 7z" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm text-gray-600">雨天地點</p>
                      <p class="font-medium text-gray-900">{{ selectedClub.rainy_location }}</p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 成員與狀態 -->
              <div class="space-y-4">
                <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">成員與狀態</h4>
                
                <div class="bg-gray-50 rounded-lg p-4">
                  <div class="flex items-center space-x-3 mb-4">
                    <div class="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                      </svg>
                    </div>
                    <div class="flex-1">
                      <p class="text-sm text-gray-600">人數狀態</p>
                      <div class="mt-1">
                        <span class="text-lg font-bold text-gray-900">
                          {{ selectedClub.current_members || 0 }} / {{ selectedClub.max_members }}
                        </span>
                        <div class="w-full bg-gray-200 rounded-full h-2 mt-1">
                          <div 
                            class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                            :style="{ width: `${Math.min((selectedClub.current_members || 0) / selectedClub.max_members * 100, 100)}%` }"
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <div class="flex-1">
                      <p class="text-sm text-gray-600">選社狀態</p>
                      <div class="mt-1">
                        <span v-if="(selectedClub.current_members || 0) >= selectedClub.max_members" class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                          </svg>
                          已滿額
                        </span>
                        <span v-else class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                          </svg>
                          可選
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 描述 -->
            <div class="mt-6">
              <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2 mb-4">社團簡介</h4>
              <div class="bg-gray-50 rounded-lg p-4">
                <p class="text-gray-700 leading-relaxed whitespace-pre-wrap">{{ selectedClub.description }}</p>
              </div>
            </div>
            
            <!-- 備註 -->
            <div v-if="selectedClub.notes" class="mt-6">
              <h4 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2 mb-4">備註</h4>
              <div class="bg-gray-50 rounded-lg p-4">
                <p class="text-gray-700 leading-relaxed whitespace-pre-wrap">{{ selectedClub.notes }}</p>
              </div>
            </div>
          </div>

          <!-- 底部按鈕 -->
          <div class="bg-gray-50 rounded-b-xl px-6 py-4">
            <div class="flex justify-end space-x-3">
              <button
                @click="showViewClubModal = false"
                class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
              >
                關閉
              </button>
              <button
                @click="editClubDetail(selectedClub); showViewClubModal = false"
                class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
              >
                編輯社團
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 編輯社團對話框 -->
    <div v-if="showEditClubModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">編輯社團</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">社團編號</label>
              <input
                v-model="editClub.code"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">社團名稱</label>
              <input
                v-model="editClub.name"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">類別</label>
              <input
                v-model="editClub.category"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">指導老師</label>
              <input
                v-model="editClub.instructor"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">最大人數</label>
              <input
                v-model="editClub.max_members"
                type="number"
                min="1"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">上課地點</label>
              <input
                v-model="editClub.location"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">簡介</label>
              <textarea
                v-model="editClub.description"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
                required
              ></textarea>
            </div>
          </div>
          <div class="flex justify-end space-x-3 mt-6">
            <button
              @click="showEditClubModal = false"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 text-gray-800"
            >
              取消
            </button>
            <button
              @click="updateClub"
              :disabled="isLoading"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {{ isLoading ? '更新中...' : '更新' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useClubStore } from '@/stores/club'
import { useAuthStore } from '@/stores/auth'
import type { Club } from '@/types/club'

const router = useRouter()
const route = useRoute()
const clubStore = useClubStore()
const authStore = useAuthStore()

// 從路由獲取學校 ID
const schoolId = computed(() => parseInt(route.params.schoolId as string))

// 響應式狀態
const clubs = ref<Club[]>([])
const searchQuery = ref('')
const selectedCategory = ref('')
const selectedCondition1 = ref('')
const selectedCondition2 = ref('')
const showAddClubModal = ref(false)
const showViewClubModal = ref(false)
const showEditClubModal = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const selectedClub = ref<Club | null>(null)

// 新增社團表單
const newClub = ref({
  code: '',
  name: '',
  category: '',
  instructor: '',
  description: '',
  max_members: 30,
  location: '',
  rainy_location: '',
  notes: '',
  condition_1: 0,
  condition_2: 0,
  condition_3: '',
  instructor_email: ''
})

// 編輯社團表單
const editClub = ref({
  code: '',
  name: '',
  category: '',
  instructor: '',
  description: '',
  max_members: 30,
  location: '',
  rainy_location: '',
  notes: '',
  condition_1: 0,
  condition_2: 0,
  condition_3: '',
  instructor_email: ''
})

// 計算屬性
const isLoading = computed(() => clubStore.isLoading)

const filteredClubs = computed(() => {
  if (!clubs.value || !Array.isArray(clubs.value)) return []
  
  let filtered = clubs.value

  // 搜尋篩選
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(club => 
      club.name.toLowerCase().includes(query) ||
      club.instructor.toLowerCase().includes(query) ||
      club.description.toLowerCase().includes(query)
    )
  }

  // 類別篩選
  if (selectedCategory.value) {
    filtered = filtered.filter(club => club.category === selectedCategory.value)
  }

  // 條件一篩選
  if (selectedCondition1.value) {
    filtered = filtered.filter(club => club.condition_1 === parseInt(selectedCondition1.value))
  }

  // 條件二篩選
  if (selectedCondition2.value) {
    filtered = filtered.filter(club => club.condition_2 === parseInt(selectedCondition2.value))
  }

  return filtered
})

const paginatedClubs = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredClubs.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredClubs.value.length / pageSize.value)
})

const availableCategories = computed(() => {
  if (!clubs.value || !Array.isArray(clubs.value)) return []
  const categories = [...new Set(clubs.value.map(c => c.category))]
  return categories.sort()
})

const availableClubs = computed(() => {
  if (!clubs.value || !Array.isArray(clubs.value)) return []
  return clubs.value.filter(club => (club.current_members || 0) < club.max_members)
})

const fullClubs = computed(() => {
  if (!clubs.value || !Array.isArray(clubs.value)) return []
  return clubs.value.filter(club => (club.current_members || 0) >= club.max_members)
})

const totalCapacity = computed(() => {
  if (!clubs.value || !Array.isArray(clubs.value)) return 0
  return clubs.value.reduce((total, club) => total + club.max_members, 0)
})

// 方法
const refreshData = async () => {
  if (!schoolId.value) return

  try {
    await clubStore.fetchClubs(schoolId.value)
    clubs.value = clubStore.clubs
    console.log('載入的社團資料:', clubs.value)
    if (clubs.value.length > 0) {
      console.log('第一個社團的資料結構:', clubs.value[0])
    }
  } catch (error) {
    console.error('載入社團資料失敗:', error)
  }
}

const addClub = async () => {
  if (!schoolId.value) return

  try {
    await clubStore.createClub(schoolId.value, {
      category: newClub.value.category,
      code: newClub.value.code,
      name: newClub.value.name,
      instructor: newClub.value.instructor,
      description: newClub.value.description,
      max_members: newClub.value.max_members,
      location: newClub.value.location,
      rainy_location: newClub.value.rainy_location,
      notes: newClub.value.notes,
      condition_1: newClub.value.condition_1,
      condition_2: newClub.value.condition_2,
      condition_3: newClub.value.condition_3,
      instructor_email: newClub.value.instructor_email
    })
    
    showAddClubModal.value = false
    resetNewClubForm()
    await refreshData()
    alert('社團新增成功')
  } catch (error) {
    console.error('新增社團失敗:', error)
    alert('新增失敗，請稍後再試')
  }
}

const viewClubDetail = (club: Club) => {
  selectedClub.value = club
  showViewClubModal.value = true
}

const editClubDetail = (club: Club) => {
  selectedClub.value = club
  console.log('編輯社團:', club)
  // 複製社團資料到編輯表單
  editClub.value = {
    code: club.code,
    name: club.name,
    category: club.category,
    instructor: club.instructor,
    description: club.description,
    max_members: club.max_members,
    location: club.location,
    rainy_location: club.rainy_location || '',
    notes: club.notes || '',
    condition_1: club.condition_1 || 0,
    condition_2: club.condition_2 || 0,
    condition_3: club.condition_3 || '',
    instructor_email: club.instructor_email || ''
  }
  showEditClubModal.value = true
}

const updateClub = async () => {
  if (!schoolId.value || !selectedClub.value) return

  try {
    const clubId = selectedClub.value.id
    console.log('更新社團 ID:', clubId, '類型:', typeof clubId)
    
    await clubStore.updateClub(schoolId.value, clubId, {
      category: editClub.value.category,
      code: editClub.value.code,
      name: editClub.value.name,
      instructor: editClub.value.instructor,
      description: editClub.value.description,
      max_members: editClub.value.max_members,
      location: editClub.value.location,
      rainy_location: editClub.value.rainy_location,
      notes: editClub.value.notes,
      condition_1: editClub.value.condition_1,
      condition_2: editClub.value.condition_2,
      condition_3: editClub.value.condition_3,
      instructor_email: editClub.value.instructor_email
    })
    
    showEditClubModal.value = false
    resetEditClubForm()
    await refreshData()
    alert('社團資料更新成功')
  } catch (error) {
    console.error('更新社團資料失敗:', error)
    alert('更新失敗，請稍後再試')
  }
}

const deleteClub = async (clubId: number, clubName: string) => {
  if (!confirm(`確定要刪除社團「${clubName}」嗎？\n\n此操作無法復原，社團的所有相關資料都將被刪除。`)) return

  try {
    await clubStore.deleteClub(schoolId.value, clubId)
    await refreshData()
    alert(`社團「${clubName}」已成功刪除`)
  } catch (error) {
    console.error('刪除社團失敗:', error)
    const errorMessage = error instanceof Error ? error.message : '未知錯誤'
    alert(`刪除失敗：${errorMessage}\n\n請稍後再試，或聯絡系統管理員`)
  }
}

const resetNewClubForm = () => {
  newClub.value = {
    code: '',
    name: '',
    category: '',
    instructor: '',
    description: '',
    max_members: 30,
    location: '',
    rainy_location: '',
    notes: '',
    condition_1: 0,
    condition_2: 0,
    condition_3: '',
    instructor_email: ''
  }
}

const resetEditClubForm = () => {
  editClub.value = {
    code: '',
    name: '',
    category: '',
    instructor: '',
    description: '',
    max_members: 30,
    location: '',
    rainy_location: '',
    notes: '',
    condition_1: 0,
    condition_2: 0,
    condition_3: '',
    instructor_email: ''
  }
}

const navigateTo = (path: string) => {
  if (!schoolId.value) return
  
  // 構建完整路徑，包含學校 ID
  const fullPath = `/schools/${schoolId.value}/admin${path.replace('/school-admin', '')}`
  router.push(fullPath)
}

// 生命週期
onMounted(() => {
  refreshData()
})
</script>
