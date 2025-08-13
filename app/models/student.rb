class Student < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  has_many :club_selections, dependent: :destroy
  has_many :clubs, through: :club_selections
  
  # 新增分發相關關聯
  has_many :club_allocations, dependent: :destroy
  has_one :club_membership, dependent: :destroy

  validates :name, presence: true
  validates :student_id, presence: true, uniqueness: { scope: :school_id }
  validates :grade, presence: true, inclusion: { in: 1..6, message: "必須在 1-6 之間" }
  validates :class_number, presence: true, numericality: { greater_than: 0 }
  validates :class_name, presence: true
  validates :seat_number, presence: true, numericality: { greater_than: 0 }
  validates :id_card_number, presence: true, uniqueness: { scope: :school_id, message: "身分證字號重複" }
  validates :special, inclusion: { in: [0, 1], message: "特殊身份標記必須是 0 或 1" }
end
