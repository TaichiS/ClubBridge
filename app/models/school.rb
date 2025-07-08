class School < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :name, presence: true
end
