import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { schoolApi } from '@/api/school'
import type { School, SchoolSetting, SchoolApplication, SchoolStatistics } from '@/types/school'

export const useSchoolStore = defineStore('school', () => {
  // State
  const current = ref<School | null>(null)
  const settings = ref<SchoolSetting | null>(null)
  const applications = ref<School[]>([])
  const statistics = ref<SchoolStatistics | null>(null)
  const isLoading = ref(false)

  // Getters
  const hasSettings = computed(() => !!settings.value)
  const isRegistrationOpen = computed(() => settings.value?.is_registration_open ?? false)
  const maxChoices = computed(() => settings.value?.max_choices ?? 3)
  const allowChangeAfterSubmit = computed(() => settings.value?.allow_change_after_submit ?? true)

  // Actions
  async function applySchool(application: SchoolApplication): Promise<School> {
    isLoading.value = true
    try {
      const school = await schoolApi.applySchool(application)
      return school
    } catch (error) {
      console.error('Apply school failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchSchool(schoolId: number): Promise<void> {
    isLoading.value = true
    try {
      const school = await schoolApi.getSchool(schoolId)
      current.value = school
    } catch (error) {
      console.error('Fetch school failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function updateSchool(schoolId: number, data: Partial<School>): Promise<void> {
    isLoading.value = true
    try {
      const school = await schoolApi.updateSchool(schoolId, data)
      current.value = school
    } catch (error) {
      console.error('Update school failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchSettings(schoolId: number): Promise<void> {
    try {
      const schoolSettings = await schoolApi.getSchoolSettings(schoolId)
      settings.value = schoolSettings
    } catch (error) {
      console.error('Fetch settings failed:', error)
      settings.value = null
    }
  }

  async function updateSettings(schoolId: number, newSettings: Partial<SchoolSetting>): Promise<void> {
    isLoading.value = true
    try {
      const schoolSettings = await schoolApi.updateSchoolSettings(schoolId, newSettings)
      settings.value = schoolSettings
    } catch (error) {
      console.error('Update settings failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function createSettings(schoolId: number, newSettings: Partial<SchoolSetting>): Promise<void> {
    isLoading.value = true
    try {
      const schoolSettings = await schoolApi.createSchoolSettings(schoolId, newSettings)
      settings.value = schoolSettings
    } catch (error) {
      console.error('Create settings failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchStatistics(schoolId: number): Promise<void> {
    try {
      const stats = await schoolApi.getSchoolStatistics(schoolId)
      statistics.value = stats
    } catch (error) {
      console.error('Fetch statistics failed:', error)
      statistics.value = null
    }
  }

  // 管理員專用功能
  async function fetchPendingApplications(): Promise<void> {
    isLoading.value = true
    try {
      const pendingSchools = await schoolApi.getPendingSchools()
      applications.value = pendingSchools
    } catch (error) {
      console.error('Fetch pending applications failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function approveSchool(schoolId: number): Promise<void> {
    isLoading.value = true
    try {
      const approvedSchool = await schoolApi.approveSchool(schoolId)
      
      // 更新 applications 列表
      const index = applications.value.findIndex(app => app.id === schoolId)
      if (index !== -1) {
        applications.value[index] = approvedSchool
      }
    } catch (error) {
      console.error('Approve school failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function rejectSchool(schoolId: number, reason?: string): Promise<void> {
    isLoading.value = true
    try {
      const rejectedSchool = await schoolApi.rejectSchool(schoolId, reason)
      
      // 更新 applications 列表
      const index = applications.value.findIndex(app => app.id === schoolId)
      if (index !== -1) {
        applications.value[index] = rejectedSchool
      }
    } catch (error) {
      console.error('Reject school failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  async function fetchAllSchools(): Promise<School[]> {
    isLoading.value = true
    try {
      const schools = await schoolApi.getAllSchools()
      return schools
    } catch (error) {
      console.error('Fetch all schools failed:', error)
      throw error
    } finally {
      isLoading.value = false
    }
  }

  function clearCurrentSchool() {
    current.value = null
    settings.value = null
    statistics.value = null
  }

  return {
    // State
    current,
    settings,
    applications,
    statistics,
    isLoading,
    
    // Getters
    hasSettings,
    isRegistrationOpen,
    maxChoices,
    allowChangeAfterSubmit,
    
    // Actions
    applySchool,
    fetchSchool,
    updateSchool,
    fetchSettings,
    updateSettings,
    createSettings,
    fetchStatistics,
    fetchPendingApplications,
    approveSchool,
    rejectSchool,
    fetchAllSchools,
    clearCurrentSchool
  }
})