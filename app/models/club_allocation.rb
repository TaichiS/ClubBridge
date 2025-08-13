class ClubAllocation < ApplicationRecord
  acts_as_tenant :school

  belongs_to :student
  belongs_to :club
  belongs_to :school

  validates :preference, presence: true, numericality: { greater_than: 0 }
  validates :student_id, uniqueness: { scope: [:club_id, :school_id], message: "學生已選擇過此社團" }
  validates :preference, uniqueness: { scope: [:student_id, :school_id], message: "志願序號重複" }

  scope :by_preference, -> { order(:preference) }
  scope :for_student, ->(student) { where(student: student) }
  scope :for_club, ->(club) { where(club: club) }
  scope :by_preference_order, ->(preference_num) { where(preference: preference_num) }

  # 從 ClubSelection 複製資料
  def self.copy_from_club_selections(school)
    transaction do
      where(school: school).delete_all
      
      ClubSelection.includes(:student, :club)
                  .where(school: school)
                  .find_each do |selection|
        create!(
          student: selection.student,
          club: selection.club,
          school: school,
          preference: selection.preference
        )
      end
    end
  end

  # 取得學生的志願列表
  def self.student_preferences(student)
    where(student: student).includes(:club).order(:preference)
  end

  # 取得社團的申請者列表，依志願序排序
  def self.club_applicants_by_preference(club, preference_num)
    where(club: club, preference: preference_num)
      .includes(:student)
      .joins(:student)
  end

  # 移除特定社團的所有志願並重新排序
  def self.remove_club_and_reorder(club, school)
    transaction do
      # 取得所有包含該社團的學生志願
      affected_students = where(club: club, school: school)
                         .pluck(:student_id)
                         .uniq

      # 刪除該社團的所有志願
      where(club: club, school: school).delete_all

      # 為每個受影響的學生重新排序志願序號
      affected_students.each do |student_id|
        student_allocations = where(student_id: student_id, school: school)
                             .order(:preference)

        student_allocations.each_with_index do |allocation, index|
          allocation.update!(preference: index + 1)
        end
      end
    end
  end

  # 檢查學生是否符合社團條件
  def student_meets_club_conditions?
    student_conditions = {
      condition1: student.condition1.to_i,  # 性別
      condition2: student.condition2.to_i,  # 學制 
      condition3: student.condition3.to_i   # 客製
    }

    club_conditions = {
      condition1: club.condition1.to_i,
      condition2: club.condition2.to_i,
      condition3: club.condition3.to_i
    }

    # 檢查每個條件，0表示無限制
    club_conditions.all? do |condition_key, club_requirement|
      club_requirement == 0 || 
      student_conditions[condition_key] == club_requirement
    end
  end
end