class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :school

  enum :role, { admin: 'admin', teacher: 'teacher' }

  validates :user_id, uniqueness: { scope: :school_id }
end
