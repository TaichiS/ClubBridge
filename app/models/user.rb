class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :schools, through: :memberships

  before_create :generate_api_token

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # 將來會使用 Pundit 和 roles 來處理權限
  # 這裡不應該有 enum :role

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
