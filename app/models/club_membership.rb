class ClubMembership < ApplicationRecord
  acts_as_tenant :school

  belongs_to :student
  belongs_to :club
  belongs_to :school

  validates :student_id, uniqueness: { scope: :school_id, message: "學生已被分配到社團" }
  validates :assignment_type, inclusion: { 
    in: ['special', 'normal', 'manual'], 
    message: "分配類型必須是 special, normal 或 manual" 
  }
  validates :allocation_round, numericality: { greater_than: 0 }, allow_nil: true
  validates :assigned_at, presence: true

  scope :special_assignments, -> { where(assignment_type: 'special') }
  scope :normal_assignments, -> { where(assignment_type: 'normal') }  
  scope :manual_assignments, -> { where(assignment_type: 'manual') }
  scope :for_club, ->(club) { where(club: club) }
  scope :for_student, ->(student) { where(student: student) }
  scope :by_assignment_time, -> { order(:assigned_at) }

  # 建立分配記錄
  def self.assign_student_to_club(student, club, assignment_type, allocation_round = nil)
    create!(
      student: student,
      club: club,
      school: student.school,
      assigned_at: Time.current,
      allocation_round: allocation_round,
      assignment_type: assignment_type
    )
  end

  # 取得社團的所有成員
  def self.club_members(club)
    includes(:student)
      .where(club: club)
      .joins(:student)
      .order('students.grade, students.class_number, students.seat_number')
  end

  # 取得特定分配類型的統計
  def self.assignment_statistics(school)
    where(school: school)
      .group(:assignment_type)
      .count
  end

  # 取得各社團的成員數統計
  def self.club_member_counts(school)
    joins(:club)
      .where(school: school)
      .group('clubs.name')
      .count
  end

  # 檢查學生是否已被分配
  def self.student_assigned?(student)
    exists?(student: student)
  end

  # 取得未分配的學生列表
  def self.unassigned_students(school)
    assigned_student_ids = where(school: school).pluck(:student_id)
    Student.where(school: school)
           .where.not(id: assigned_student_ids)
  end

  # 清空學校的所有分配記錄
  def self.clear_school_assignments(school)
    where(school: school).delete_all
  end
end