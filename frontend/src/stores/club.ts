import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { clubApi } from '@/api/club'
import type { Club, ClubFilter, ClubStatistics, ClubSelection, ClubSelectionRequest } from '@/types/club'

export const useClubStore = defineStore('club', () => {
  // State
  const clubs = ref<Club[]>([])
  const currentClub = ref<Club | null>(null)
  const statistics = ref<ClubStatistics | null>(null)
  const realtimeStats = ref<any>(null)
  const filters = ref<ClubFilter>({})
  const isLoading = ref(false)
  const importProgress = ref(0)

  // 選社相關狀態
  const selections = ref<ClubSelection[]>([])
  const currentSelections = ref<number[]>([]) // 當前學生的選社志願（club IDs）
  const assignmentResults = ref<any>(null)

  // Getters
  const filteredClubs = computed(() => {
    let result = clubs.value

    if (filters.value.category) {
      result = result.filter(c => c.category === filters.value.category)
    }

    if (filters.value.search) {
      const search = filters.value.search.toLowerCase()
      result = result.filter(c => 
        c.name.toLowerCase().includes(search) ||
        c.instructor.toLowerCase().includes(search) ||
        c.description.toLowerCase().includes(search)
      )
    }

    if (filters.value.condition_1) {
      result = result.filter(c => c.condition_1 === filters.value.condition_1)
    }

    if (filters.value.condition_2) {
      result = result.filter(c => c.condition_2 === filters.value.condition_2)
    }

    if (filters.value.has_available_spots) {
      result = result.filter(c => (c.current_members || 0) < c.max_members)
    }

    return result
  })

  const totalClubs = computed(() => clubs.value.length)
  const categoryOptions = computed(() => {
    const categories = [...new Set(clubs.value.map(c => c.category))].sort()
    return categories.map(category => ({ value: category, label: category }))
  })

  const availableClubs = computed(() => {
    return clubs.value.filter(c => (c.current_members || 0) < c.max_members)
  })

  const fullClubs = computed(() => {
    return clubs.value.filter(c => (c.current_members || 0) >= c.max_members)
  })

  // Actions
  async function fetchClubs(schoolId: number, newFilters?: ClubFilter): Promise<void> {
    isLoading.value = true
    try {
      const fetchedClubs = await clubApi.getClubs(schoolId, newFilters)
      clubs.value = fetchedClubs
      
      if (newFilters) {
        filters.value = { ...newFilters }
      }
    } catch (error) {
      console.error('Fetch clubs failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchClub(schoolId: number, clubId: number): Promise<void> {
    isLoading.value = true
    try {
      const club = await clubApi.getClub(schoolId, clubId)
      currentClub.value = club
    } catch (error) {
      console.error('Fetch club failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function createClub(schoolId: number, clubData: Omit<Club, 'id' | 'school_id' | 'current_members' | 'created_at' | 'updated_at'>): Promise<void> {
    isLoading.value = true
    try {
      const newClub = await clubApi.createClub(schoolId, clubData)
      clubs.value.push(newClub)
    } catch (error) {
      console.error('Create club failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function updateClub(schoolId: number, clubId: number, clubData: Partial<Club>): Promise<void> {
    isLoading.value = true
    try {
      const updatedClub = await clubApi.updateClub(schoolId, clubId, clubData)
      
      const index = clubs.value.findIndex(c => c.id === clubId)
      if (index !== -1) {
        clubs.value[index] = updatedClub
      }

      if (currentClub.value?.id === clubId) {
        currentClub.value = updatedClub
      }
    } catch (error) {
      console.error('Update club failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function deleteClub(schoolId: number, clubId: number): Promise<void> {
    isLoading.value = true
    try {
      await clubApi.deleteClub(schoolId, clubId)
      
      clubs.value = clubs.value.filter(c => c.id !== clubId)
      
      if (currentClub.value?.id === clubId) {
        currentClub.value = null
      }
    } catch (error) {
      console.error('Delete club failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function deleteClubs(schoolId: number, clubIds: number[]): Promise<void> {
    isLoading.value = true
    try {
      await clubApi.deleteClubs(schoolId, clubIds)
      
      clubs.value = clubs.value.filter(c => !clubIds.includes(c.id))
    } catch (error) {
      console.error('Delete clubs failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function importClubs(schoolId: number, file: File): Promise<{
    imported: number
    errors: string[]
    preview: Club[]
  }> {
    isLoading.value = true
    importProgress.value = 0
    
    try {
      const result = await clubApi.importClubs(schoolId, file, (progress) => {
        importProgress.value = progress
      })

      // 重新載入社團列表
      await fetchClubs(schoolId)
      
      return result
    } catch (error) {
      console.error('Import clubs failed:', error)
      throw error
    } finally {
      isLoading.value = false
      importProgress.value = 0
    }
  }

  async function exportClubs(schoolId: number, format: 'excel' | 'csv' | 'json' = 'excel'): Promise<void> {
    isLoading.value = true
    try {
      const blob = await clubApi.exportClubs(schoolId, format)
      
      // 下載檔案
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `clubs.${format === 'excel' ? 'xlsx' : format}`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Export clubs failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchStatistics(schoolId: number): Promise<void> {
    try {
      const stats = await clubApi.getClubStatistics(schoolId)
      statistics.value = stats
    } catch (error) {
      console.error('Fetch statistics failed:', error)
      statistics.value = null
    }
  }

  async function fetchRealtimeStats(schoolId: number): Promise<void> {
    try {
      const stats = await clubApi.getRealtimeStats(schoolId)
      realtimeStats.value = stats
    } catch (error) {
      console.error('Fetch realtime stats failed:', error)
      realtimeStats.value = null
    }
  }

  async function searchClubs(schoolId: number, query: string): Promise<Club[]> {
    try {
      return await clubApi.searchClubs(schoolId, query)
    } catch (error) {
      console.error('Search clubs failed:', error)
      throw error
    }
  }

  // 選社相關功能
  async function submitClubSelection(schoolId: number, studentId: number, clubChoices: number[]): Promise<void> {
    isLoading.value = true
    try {
      const selectionRequest: ClubSelectionRequest = { club_choices: clubChoices }
      const newSelections = await clubApi.submitClubSelection(schoolId, studentId, selectionRequest)
      selections.value = newSelections
      currentSelections.value = clubChoices
    } catch (error) {
      console.error('Submit club selection failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchStudentSelections(schoolId: number, studentId: number): Promise<void> {
    try {
      const studentSelections = await clubApi.getStudentSelections(schoolId, studentId)
      selections.value = studentSelections
      
      // 更新當前選擇的社團 IDs（按優先順序排列）
      currentSelections.value = studentSelections
        .sort((a, b) => a.priority - b.priority)
        .map(s => s.club_id)
    } catch (error) {
      console.error('Fetch student selections failed:', error)
      selections.value = []
      currentSelections.value = []
    }
  }

  async function fetchAllSelections(schoolId: number): Promise<void> {
    isLoading.value = true
    try {
      const allSelections = await clubApi.getAllSelections(schoolId)
      selections.value = allSelections
    } catch (error) {
      console.error('Fetch all selections failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function startAssignment(schoolId: number): Promise<{
    message: string
    assigned: number
    unassigned: number
  }> {
    isLoading.value = true
    try {
      const result = await clubApi.startAssignment(schoolId)
      
      // 重新載入統計數據
      await fetchRealtimeStats(schoolId)
      
      return result
    } catch (error) {
      console.error('Start assignment failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchAssignmentResults(schoolId: number): Promise<void> {
    isLoading.value = true
    try {
      const results = await clubApi.getAssignmentResults(schoolId)
      assignmentResults.value = results
    } catch (error) {
      console.error('Fetch assignment results failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  function setFilters(newFilters: ClubFilter) {
    filters.value = { ...newFilters }
  }

  function clearFilters() {
    filters.value = {}
  }

  function clearCurrentClub() {
    currentClub.value = null
  }

  function clearClubs() {
    clubs.value = []
    statistics.value = null
    realtimeStats.value = null
  }

  function updateCurrentSelections(clubChoices: number[]) {
    currentSelections.value = [...clubChoices]
  }

  return {
    // State
    clubs,
    currentClub,
    statistics,
    realtimeStats,
    filters,
    isLoading,
    importProgress,
    selections,
    currentSelections,
    assignmentResults,
    
    // Getters
    filteredClubs,
    totalClubs,
    categoryOptions,
    availableClubs,
    fullClubs,
    
    // Actions
    fetchClubs,
    fetchClub,
    createClub,
    updateClub,
    deleteClub,
    deleteClubs,
    importClubs,
    exportClubs,
    fetchStatistics,
    fetchRealtimeStats,
    searchClubs,
    submitClubSelection,
    fetchStudentSelections,
    fetchAllSelections,
    startAssignment,
    fetchAssignmentResults,
    setFilters,
    clearFilters,
    clearCurrentClub,
    clearClubs,
    updateCurrentSelections
  }
})