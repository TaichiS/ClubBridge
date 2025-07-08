class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :schools, through: :memberships

  enum :role, { school_user: 'school_user', super_admin: 'super_admin' }

  before_create :generate_api_token

  validates :email, presence: true, uniqueness: true

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(16)
  end
end
