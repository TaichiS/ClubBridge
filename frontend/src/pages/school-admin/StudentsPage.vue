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
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">年級</label>
          <select
            v-model="selectedGrade"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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
                {{ student.student_id }}
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
                <span v-if="student.has_selection" class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
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
                  @click="editStudent(student)"
                  class="text-green-600 hover:text-green-900 mr-3"
                >
                  編輯
                </button>
                <button
                  @click="deleteStudent(student.id)"
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
              class="px-3 py-1 text-sm bg-gray-200 rounded disabled:opacity-50"
            >
              上一頁
            </button>
            <button
              @click="currentPage++"
              :disabled="currentPage >= totalPages"
              class="px-3 py-1 text-sm bg-gray-200 rounded disabled:opacity-50"
            >
              下一頁
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新增學生對話框 -->
    <div v-if="showAddStudentModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">新增學生</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">學號</label>
              <input
                v-model="newStudent.student_id"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">姓名</label>
              <input
                v-model="newStudent.name"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">年級</label>
                <select
                  v-model="newStudent.grade"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">班級</label>
                <input
                  v-model="newStudent.class_name"
                  type="text"
                  placeholder="例: 忠"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">座號</label>
              <input
                v-model="newStudent.seat_number"
                type="number"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">身分證字號</label>
              <input
                v-model="newStudent.id_number"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
          </div>
          <div class="flex justify-end space-x-3 mt-6">
            <button
              @click="showAddStudentModal = false"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
            >
              取消
            </button>
            <button
              @click="addStudent"
              :disabled="isLoading"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {{ isLoading ? '新增中...' : '新增' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useStudentStore } from '@/stores/student'
import { useAuthStore } from '@/stores/auth'
import type { Student } from '@/types/student'

const router = useRouter()
const studentStore = useStudentStore()
const authStore = useAuthStore()

// 響應式狀態
const students = ref<Student[]>([])
const searchQuery = ref('')
const selectedGrade = ref('')
const selectedClass = ref('')
const selectedStatus = ref('')
const showAddStudentModal = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)

// 新增學生表單
const newStudent = ref({
  student_id: '',
  name: '',
  grade: '',
  class_name: '',
  seat_number: '',
  id_number: ''
})

// 計算屬性
const isLoading = computed(() => studentStore.isLoading)

const filteredStudents = computed(() => {
  let filtered = students.value

  // 搜尋篩選
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(student => 
      student.student_id.toLowerCase().includes(query) ||
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
  const classes = [...new Set(students.value.map(s => s.class_name))]
  return classes.sort()
})

const studentsWithSelection = computed(() => {
  return students.value.filter(student => student.has_selection)
})

const studentsWithoutSelection = computed(() => {
  return students.value.filter(student => !student.has_selection)
})

const assignedStudents = computed(() => {
  return students.value.filter(student => student.assigned_club)
})

// 方法
const refreshData = async () => {
  const currentSchool = authStore.currentSchool
  if (!currentSchool) return

  try {
    students.value = await studentStore.fetchStudents(currentSchool.id)
  } catch (error) {
    console.error('載入學生資料失敗:', error)
  }
}

const addStudent = async () => {
  const currentSchool = authStore.currentSchool
  if (!currentSchool) return

  try {
    await studentStore.createStudent(currentSchool.id, {
      ...newStudent.value,
      grade: parseInt(newStudent.value.grade),
      seat_number: parseInt(newStudent.value.seat_number),
      class_number: 1 // 這裡可能需要根據班級名稱計算
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

const editStudent = (student: Student) => {
  // 這裡可以開啟編輯對話框
  console.log('編輯學生:', student)
}

const viewStudentDetail = (student: Student) => {
  // 這裡可以開啟學生詳情頁面
  console.log('查看學生詳情:', student)
}

const deleteStudent = async (studentId: number) => {
  if (!confirm('確定要刪除此學生嗎？')) return

  try {
    await studentStore.deleteStudent(studentId)
    await refreshData()
    alert('學生刪除成功')
  } catch (error) {
    console.error('刪除學生失敗:', error)
    alert('刪除失敗，請稍後再試')
  }
}

const resetNewStudentForm = () => {
  newStudent.value = {
    student_id: '',
    name: '',
    grade: '',
    class_name: '',
    seat_number: '',
    id_number: ''
  }
}

const navigateTo = (path: string) => {
  router.push(path)
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

// 生命週期
onMounted(() => {
  refreshData()
})
</script>