<template>
  <div class="p-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-900">用戶權限管理</h1>
      <button
        @click="refreshUsers"
        :disabled="isLoading"
        class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {{ isLoading ? '載入中...' : '重新整理' }}
      </button>
    </div>

    <!-- 搜尋和篩選 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="form-label">搜尋用戶</label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜尋姓名或信箱..."
            class="form-input"
            @input="debouncedSearch"
          />
        </div>
        <div>
          <label class="form-label">角色篩選</label>
          <select v-model="roleFilter" class="form-input" @change="applyFilters">
            <option value="">所有角色</option>
            <option value="super_admin">超級管理員</option>
            <option value="school_admin">學校管理員</option>
            <option value="teacher">社團老師</option>
          </select>
        </div>
        <div>
          <label class="form-label">顯示筆數</label>
          <select v-model="perPage" class="form-input" @change="loadUsers(1)">
            <option value="10">10</option>
            <option value="20">20</option>
            <option value="50">50</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 用戶列表 -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
      <div v-if="isLoading" class="p-8 text-center">
        <div class="text-lg text-gray-600">載入中...</div>
      </div>
      
      <div v-else-if="users.length === 0" class="p-8 text-center">
        <div class="text-lg text-gray-600">沒有找到用戶</div>
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                用戶資訊
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                角色
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                學校權限
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                建立時間
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                操作
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900">{{ user.name }}</div>
                  <div class="text-sm text-gray-500">{{ user.email }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="getRoleClass(user.user_role)">
                  {{ user.user_role_text }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="space-y-1">
                  <div v-if="user.schools.length === 0" class="text-sm text-gray-500">
                    無學校權限
                  </div>
                  <div v-else v-for="school in user.schools" :key="school.id" class="text-sm">
                    <span class="font-medium text-gray-900">{{ school.name }}</span>
                    <span class="ml-2 text-gray-500">({{ school.membership_role }})</span>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(user.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openEditModal(user)"
                  class="text-blue-600 hover:text-blue-900"
                >
                  編輯
                </button>
                <button
                  @click="openSchoolModal(user)"
                  class="text-green-600 hover:text-green-900"
                >
                  管理學校
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 分頁控制 -->
    <div v-if="meta && meta.total_pages > 1" class="mt-6 flex items-center justify-between">
      <div class="text-sm text-gray-700">
        共 {{ meta.total_count }} 個用戶，第 {{ meta.current_page }} / {{ meta.total_pages }} 頁
      </div>
      <div class="flex space-x-2">
        <button
          @click="loadUsers(meta.current_page - 1)"
          :disabled="meta.current_page <= 1"
          class="px-3 py-2 bg-white border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50"
        >
          上一頁
        </button>
        <button
          @click="loadUsers(meta.current_page + 1)"
          :disabled="meta.current_page >= meta.total_pages"
          class="px-3 py-2 bg-white border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50"
        >
          下一頁
        </button>
      </div>
    </div>

    <!-- 編輯用戶模態框 -->
    <div v-if="showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">編輯用戶</h3>
          
          <div class="space-y-4">
            <div>
              <label class="form-label">姓名</label>
              <input
                v-model="editForm.name"
                type="text"
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">信箱</label>
              <input
                v-model="editForm.email"
                type="email"
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">角色</label>
              <select v-model="editForm.user_role" class="form-input">
                <option value="school_admin">學校管理員</option>
                <option value="super_admin">超級管理員</option>
                <option value="teacher">社團老師</option>
              </select>
            </div>
          </div>
          
          <div class="flex space-x-4 mt-6">
            <button
              @click="saveUser"
              :disabled="isSaving"
              class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {{ isSaving ? '儲存中...' : '儲存' }}
            </button>
            <button
              @click="closeEditModal"
              :disabled="isSaving"
              class="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400 disabled:opacity-50"
            >
              取消
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 管理學校模態框 -->
    <div v-if="showSchoolModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-[600px] shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">
            管理 {{ selectedUser?.name }} 的學校權限
          </h3>
          
          <!-- 現有學校權限 -->
          <div class="mb-6">
            <h4 class="text-md font-medium text-gray-900 mb-2">現有權限</h4>
            <div v-if="selectedUser?.schools.length === 0" class="text-sm text-gray-500">
              尚無學校權限
            </div>
            <div v-else class="space-y-2">
              <div v-for="school in selectedUser?.schools" :key="school.id" 
                   class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div>
                  <span class="font-medium">{{ school.name }}</span>
                  <span class="ml-2 text-sm text-gray-500">({{ school.membership_role }})</span>
                </div>
                <button
                  @click="removeSchool(school.id)"
                  class="text-red-600 hover:text-red-900 text-sm"
                >
                  移除
                </button>
              </div>
            </div>
          </div>
          
          <!-- 添加新學校 -->
          <div class="mb-6">
            <h4 class="text-md font-medium text-gray-900 mb-2">添加學校權限</h4>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="form-label">選擇學校</label>
                <select v-model="newSchoolId" class="form-input">
                  <option value="">請選擇學校</option>
                  <option v-for="school in availableSchools" :key="school.id" :value="school.id">
                    {{ school.name }}
                  </option>
                </select>
              </div>
              <div>
                <label class="form-label">角色</label>
                <select v-model="newSchoolRole" class="form-input">
                  <option value="admin">管理員</option>
                  <option value="teacher">老師</option>
                </select>
              </div>
            </div>
            <button
              @click="addSchool"
              :disabled="!newSchoolId || isManagingSchool"
              class="mt-2 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50"
            >
              {{ isManagingSchool ? '處理中...' : '添加' }}
            </button>
          </div>
          
          <div class="flex justify-end">
            <button
              @click="closeSchoolModal"
              class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
            >
              關閉
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { userApi, type User, type UsersResponse } from '@/api/user'
import { schoolApi } from '@/api/school'
import type { School } from '@/types/school'

// 響應式狀態
const users = ref<User[]>([])
const allSchools = ref<School[]>([])
const meta = ref<UsersResponse['meta'] | null>(null)
const isLoading = ref(false)
const isSaving = ref(false)
const isManagingSchool = ref(false)

// 搜尋和篩選
const searchQuery = ref('')
const roleFilter = ref('')
const perPage = ref(20)

// 模態框狀態
const showEditModal = ref(false)
const showSchoolModal = ref(false)
const selectedUser = ref<User | null>(null)

// 編輯表單
const editForm = ref({
  name: '',
  email: '',
  user_role: ''
})

// 學校管理
const newSchoolId = ref('')
const newSchoolRole = ref('admin')

// 計算屬性
const availableSchools = computed(() => {
  if (!selectedUser.value) return allSchools.value
  
  const userSchoolIds = selectedUser.value.schools.map(s => s.id)
  return allSchools.value.filter(school => !userSchoolIds.includes(school.id))
})

// 方法
const loadUsers = async (page: number = 1) => {
  isLoading.value = true
  try {
    const response = await userApi.getUsers(page, perPage.value)
    users.value = response.users
    meta.value = response.meta
  } catch (error) {
    console.error('載入用戶失敗:', error)
    alert('載入用戶失敗')
  } finally {
    isLoading.value = false
  }
}

const loadSchools = async () => {
  try {
    allSchools.value = await schoolApi.getAllSchools()
  } catch (error) {
    console.error('載入學校失敗:', error)
  }
}

const refreshUsers = () => {
  loadUsers(1)
}

const applyFilters = () => {
  // TODO: 實作篩選邏輯
  loadUsers(1)
}

const debouncedSearch = () => {
  // TODO: 實作搜尋邏輯
  setTimeout(() => {
    applyFilters()
  }, 300)
}

const openEditModal = (user: User) => {
  selectedUser.value = user
  editForm.value = {
    name: user.name,
    email: user.email,
    user_role: user.user_role
  }
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
  selectedUser.value = null
}

const saveUser = async () => {
  if (!selectedUser.value) return
  
  isSaving.value = true
  try {
    const updatedUser = await userApi.updateUser(selectedUser.value.id, editForm.value)
    
    // 更新本地用戶列表
    const index = users.value.findIndex(u => u.id === updatedUser.id)
    if (index !== -1) {
      users.value[index] = updatedUser
    }
    
    closeEditModal()
    alert('用戶更新成功')
  } catch (error) {
    console.error('更新用戶失敗:', error)
    alert('更新用戶失敗')
  } finally {
    isSaving.value = false
  }
}

const openSchoolModal = (user: User) => {
  selectedUser.value = user
  newSchoolId.value = ''
  newSchoolRole.value = 'admin'
  showSchoolModal.value = true
}

const closeSchoolModal = () => {
  showSchoolModal.value = false
  selectedUser.value = null
}

const addSchool = async () => {
  if (!selectedUser.value || !newSchoolId.value) return
  
  isManagingSchool.value = true
  try {
    const updatedUser = await userApi.addSchoolToUser(
      selectedUser.value.id,
      parseInt(newSchoolId.value),
      newSchoolRole.value
    )
    
    // 更新本地用戶資料
    selectedUser.value = updatedUser
    const index = users.value.findIndex(u => u.id === updatedUser.id)
    if (index !== -1) {
      users.value[index] = updatedUser
    }
    
    newSchoolId.value = ''
    alert('學校權限添加成功')
  } catch (error) {
    console.error('添加學校權限失敗:', error)
    alert('添加學校權限失敗')
  } finally {
    isManagingSchool.value = false
  }
}

const removeSchool = async (schoolId: number) => {
  if (!selectedUser.value) return
  
  if (!confirm('確定要移除此學校權限嗎？')) return
  
  isManagingSchool.value = true
  try {
    const updatedUser = await userApi.removeSchoolFromUser(selectedUser.value.id, schoolId)
    
    // 更新本地用戶資料
    selectedUser.value = updatedUser
    const index = users.value.findIndex(u => u.id === updatedUser.id)
    if (index !== -1) {
      users.value[index] = updatedUser
    }
    
    alert('學校權限移除成功')
  } catch (error) {
    console.error('移除學校權限失敗:', error)
    alert('移除學校權限失敗')
  } finally {
    isManagingSchool.value = false
  }
}

const getRoleClass = (role: string) => {
  switch (role) {
    case 'super_admin':
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800'
    case 'school_admin':
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800'
    case 'teacher':
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800'
    default:
      return 'px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800'
  }
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 生命週期
onMounted(() => {
  loadUsers()
  loadSchools()
})
</script>