class Club < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  has_many :club_selections
  has_many :students, through: :club_selections

  validates :category, presence: true
  validates :club_number, presence: true, uniqueness: { scope: :school_id }
  validates :name, presence: true
  validates :teacher_name, presence: true
  validates :description, presence: true, length: { maximum: 500 }
  validates :max_members, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true

  # 計算目前社團成員數量
  def current_members
    club_selections.count
  end

  # 計算可用名額
  def available_spots
    max_members - current_members
  end

  # 檢查是否還有名額
  def has_available_spots?
    available_spots > 0
  end
end
