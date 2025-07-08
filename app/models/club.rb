class Club < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  validates :category, presence: true
  validates :club_number, presence: true, uniqueness: { scope: :school_id }
  validates :name, presence: true
  validates :teacher_name, presence: true
  validates :description, presence: true, length: { maximum: 500 }
  validates :max_members, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
end
