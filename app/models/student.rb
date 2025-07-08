class Student < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  validates :name, presence: true
  validates :student_id, presence: true, uniqueness: { scope: :school_id }
end
