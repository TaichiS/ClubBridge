// 社團相關類型定義

export interface ClubPublicInfo {
  id: string
  name: string
  category: string
  categoryColor: string
  teacher: string
  teacherEmail?: string
  description: string
  maxCapacity: number
  currentCount: number
  availableSpots: number
  location: string
  rainLocation?: string
  requirements: ClubRequirements
  schedule: string
  images: string[]
  tags: string[]
  isPopular: boolean
  rating?: number
  reviews?: ClubReview[]
  activities?: ClubActivity[]
}

export interface ClubRequirements {
  gender?: 'male' | 'female' | 'both'
  grades: string[]
  specialRequirements?: string
  hasPhysicalRequirements: boolean
  requiresEquipment: boolean
  cost?: number
}

export interface ClubReview {
  id: string
  studentName: string
  rating: number
  comment: string
  createdAt: Date
  semester: string
}

export interface ClubActivity {
  id: string
  title: string
  description: string
  date: Date
  images: string[]
  type: 'competition' | 'exhibition' | 'practice' | 'event'
}

export interface ClubFilter {
  categories: string[]
  grades: string[]
  hasAvailableSpots: boolean
  maxCost?: number
  searchTerm: string
  sortBy: 'name' | 'popularity' | 'available' | 'rating'
  sortOrder: 'asc' | 'desc'
}

export interface ClubCard {
  id: string
  name: string
  category: string
  categoryColor: string
  teacher: string
  currentCount: number
  maxCapacity: number
  availableSpots: number
  location: string
  image: string
  isPopular: boolean
  rating?: number
  tags: string[]
}