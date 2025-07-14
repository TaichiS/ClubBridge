// 學生相關類型定義

export interface StudentInfo {
  id: string
  studentId: string
  name: string
  grade: number
  class: string
  classNumber: number
  gender: 'male' | 'female'
  idNumber: string
  schoolId: string
  isSpecialStudent: boolean
  specialConditions?: string[]
}

export interface StudentAuth {
  isAuthenticated: boolean
  token?: string
  studentInfo?: StudentInfo
  permissions: string[]
}

export interface SelectionData {
  id: string
  studentId: string
  preferences: ClubPreference[]
  submittedAt?: Date
  status: 'draft' | 'submitted' | 'assigned' | 'cancelled'
  finalAssignment?: FinalAssignment
}

export interface ClubPreference {
  id: string
  clubId: string
  clubName: string
  clubCategory: string
  clubImage: string
  priority: number
  reason?: string
  isEligible: boolean
  eligibilityReason?: string
}

export interface FinalAssignment {
  clubId: string
  clubName: string
  clubCategory: string
  clubTeacher: string
  clubLocation: string
  clubSchedule: string
  assignedAt: Date
  preference: number
  isWaitlisted: boolean
  waitlistPosition?: number
}

export interface SelectionResult {
  studentId: string
  assignment: FinalAssignment
  alternativeClubs: AlternativeClub[]
  message?: string
  canTransfer: boolean
  transferDeadline?: Date
}

export interface AlternativeClub {
  clubId: string
  clubName: string
  availableSpots: number
  priority: number
}

export interface DragState {
  isDragging: boolean
  draggedItem?: ClubPreference
  draggedIndex?: number
  dropZoneActive: boolean
  draggedOverIndex?: number
}

export interface SelectionAnimation {
  type: 'add' | 'remove' | 'reorder' | 'submit'
  clubId?: string
  fromIndex?: number
  toIndex?: number
  duration: number
}