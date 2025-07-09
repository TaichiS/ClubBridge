class ClubSelection < ApplicationRecord
  acts_as_tenant :school

  belongs_to :student
  belongs_to :club

  validates :preference, presence: true
end
