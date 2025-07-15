class ClubSelection < ApplicationRecord
  acts_as_tenant :school

  belongs_to :student
  belongs_to :club

  validates :preference, presence: true, uniqueness: { scope: :student_id }
  validates :student_id, uniqueness: { scope: :club_id, message: "已經選擇過此社團" }
  validates :preference, numericality: { greater_than: 0 }

  scope :by_preference, -> { order(:preference) }
  scope :for_student, ->(student) { where(student: student) }
  scope :for_club, ->(club) { where(club: club) }

  # 取得學生的志願列表
  def self.student_preferences(student)
    where(student: student).includes(:club).order(:preference)
  end

  # 取得社團的志願者列表
  def self.club_applicants(club)
    where(club: club).includes(:student).order(:preference)
  end

  # 檢查是否達到最少志願數
  def self.meets_minimum_requirements?(student, min_required)
    where(student: student).count >= min_required
  end
end
