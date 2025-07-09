class School < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  has_many :students, dependent: :destroy
  has_many :clubs, dependent: :destroy
  has_many :club_selections, dependent: :destroy
  has_one :school_setting, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :name, presence: true
end
