class Student < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  has_many :club_selections, dependent: :destroy
  has_many :clubs, through: :club_selections

  validates :name, presence: true
  validates :student_id, presence: true, uniqueness: { scope: :school_id }
end
