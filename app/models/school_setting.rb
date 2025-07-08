class SchoolSetting < ApplicationRecord
  belongs_to :school
  acts_as_tenant :school

  validates :school_id, uniqueness: true
end
