class School < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  has_many :students, dependent: :destroy
  has_many :clubs, dependent: :destroy

  validates :name, presence: true
end
