// 學校相關類型定義

export interface SchoolPublicInfo {
  id: string
  name: string
  logo: string
  description: string
  announcements: Announcement[]
  selectionSchedule: SelectionSchedule
  clubStats: ClubStats
  theme: SchoolTheme
}

export interface Announcement {
  id: string
  title: string
  content: string
  createdAt: Date
  priority: 'high' | 'medium' | 'low'
  isSticky: boolean
}

export interface SelectionSchedule {
  registrationStart: Date
  registrationEnd: Date
  assignmentDate: Date
  resultAnnouncement: Date
  isRegistrationOpen: boolean
}

export interface ClubStats {
  totalClubs: number
  availableClubs: number
  totalCapacity: number
  currentRegistrations: number
  categories: CategoryStats[]
}

export interface CategoryStats {
  name: string
  count: number
  color: string
}

export interface SchoolTheme {
  primaryColor: string
  secondaryColor: string
  accentColor: string
  logoUrl: string
  backgroundPattern?: string
}