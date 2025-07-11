import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { studentApi } from '@/api/student'
import type { Student, StudentFilter, StudentStatistics } from '@/types/student'

export const useStudentStore = defineStore('student', () => {
  // State
  const students = ref<Student[]>([])
  const currentStudent = ref<Student | null>(null)
  const statistics = ref<StudentStatistics | null>(null)
  const filters = ref<StudentFilter>({})
  const isLoading = ref(false)
  const importProgress = ref(0)

  // Getters
  const filteredStudents = computed(() => {
    let result = students.value

    if (filters.value.grade) {
      result = result.filter(s => s.grade === filters.value.grade)
    }

    if (filters.value.class_number) {
      result = result.filter(s => s.class_number === filters.value.class_number)
    }

    if (filters.value.class_name) {
      result = result.filter(s => s.class_name === filters.value.class_name)
    }

    if (filters.value.search) {
      const search = filters.value.search.toLowerCase()
      result = result.filter(s => 
        s.name.toLowerCase().includes(search) ||
        s.student_number.toLowerCase().includes(search)
      )
    }

    if (filters.value.condition_1) {
      result = result.filter(s => s.condition_1 === filters.value.condition_1)
    }

    if (filters.value.condition_2) {
      result = result.filter(s => s.condition_2 === filters.value.condition_2)
    }

    return result
  })

  const totalStudents = computed(() => students.value.length)
  const gradeOptions = computed(() => {
    const grades = [...new Set(students.value.map(s => s.grade))].sort()
    return grades.map(grade => ({ value: grade, label: `${grade}年級` }))
  })

  const classOptions = computed(() => {
    const classes = [...new Set(students.value.map(s => s.class_name))].sort()
    return classes.map(className => ({ value: className, label: className }))
  })

  // Actions
  async function fetchStudents(schoolId: number, newFilters?: StudentFilter): Promise<void> {
    isLoading.value = true
    try {
      const fetchedStudents = await studentApi.getStudents(schoolId, newFilters)
      students.value = fetchedStudents
      
      if (newFilters) {
        filters.value = { ...newFilters }
      }
    } catch (error) {
      console.error('Fetch students failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchStudent(schoolId: number, studentId: number): Promise<void> {
    isLoading.value = true
    try {
      const student = await studentApi.getStudent(schoolId, studentId)
      currentStudent.value = student
    } catch (error) {
      console.error('Fetch student failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function createStudent(schoolId: number, studentData: Omit<Student, 'id' | 'school_id' | 'created_at' | 'updated_at'>): Promise<void> {
    isLoading.value = true
    try {
      const newStudent = await studentApi.createStudent(schoolId, studentData)
      students.value.push(newStudent)
    } catch (error) {
      console.error('Create student failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function updateStudent(schoolId: number, studentId: number, studentData: Partial<Student>): Promise<void> {
    isLoading.value = true
    try {
      const updatedStudent = await studentApi.updateStudent(schoolId, studentId, studentData)
      
      const index = students.value.findIndex(s => s.id === studentId)
      if (index !== -1) {
        students.value[index] = updatedStudent
      }

      if (currentStudent.value?.id === studentId) {
        currentStudent.value = updatedStudent
      }
    } catch (error) {
      console.error('Update student failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function deleteStudent(schoolId: number, studentId: number): Promise<void> {
    isLoading.value = true
    try {
      await studentApi.deleteStudent(schoolId, studentId)
      
      students.value = students.value.filter(s => s.id !== studentId)
      
      if (currentStudent.value?.id === studentId) {
        currentStudent.value = null
      }
    } catch (error) {
      console.error('Delete student failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function deleteStudents(schoolId: number, studentIds: number[]): Promise<void> {
    isLoading.value = true
    try {
      await studentApi.deleteStudents(schoolId, studentIds)
      
      students.value = students.value.filter(s => !studentIds.includes(s.id))
    } catch (error) {
      console.error('Delete students failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function importStudents(schoolId: number, file: File): Promise<{
    imported: number
    errors: string[]
    preview: Student[]
  }> {
    isLoading.value = true
    importProgress.value = 0
    
    try {
      const result = await studentApi.importStudents(schoolId, file, (progress) => {
        importProgress.value = progress
      })

      // 重新載入學生列表
      await fetchStudents(schoolId)
      
      return result
    } catch (error) {
      console.error('Import students failed:', error)
      throw error
    } finally {
      isLoading.value = false
      importProgress.value = 0
    }
  }

  async function exportStudents(schoolId: number, format: 'excel' | 'csv' | 'json' = 'excel'): Promise<void> {
    isLoading.value = true
    try {
      const blob = await studentApi.exportStudents(schoolId, format)
      
      // 下載檔案
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `students.${format === 'excel' ? 'xlsx' : format}`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Export students failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchStatistics(schoolId: number): Promise<void> {
    try {
      const stats = await studentApi.getStudentStatistics(schoolId)
      statistics.value = stats
    } catch (error) {
      console.error('Fetch statistics failed:', error)
      statistics.value = null
    }
  }

  async function searchStudents(schoolId: number, query: string): Promise<Student[]> {
    try {
      return await studentApi.searchStudents(schoolId, query)
    } catch (error) {
      console.error('Search students failed:', error)
      throw error
    }
  }

  async function resetStudentSelection(schoolId: number, studentId: number): Promise<void> {
    isLoading.value = true
    try {
      await studentApi.resetStudentSelection(schoolId, studentId)
    } catch (error) {
      console.error('Reset student selection failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  function setFilters(newFilters: StudentFilter) {
    filters.value = { ...newFilters }
  }

  function clearFilters() {
    filters.value = {}
  }

  function clearCurrentStudent() {
    currentStudent.value = null
  }

  function clearStudents() {
    students.value = []
    statistics.value = null
  }

  return {
    // State
    students,
    currentStudent,
    statistics,
    filters,
    isLoading,
    importProgress,
    
    // Getters
    filteredStudents,
    totalStudents,
    gradeOptions,
    classOptions,
    
    // Actions
    fetchStudents,
    fetchStudent,
    createStudent,
    updateStudent,
    deleteStudent,
    deleteStudents,
    importStudents,
    exportStudents,
    fetchStatistics,
    searchStudents,
    resetStudentSelection,
    setFilters,
    clearFilters,
    clearCurrentStudent,
    clearStudents
  }
})