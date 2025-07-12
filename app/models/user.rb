class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :schools, through: :memberships

  before_create :generate_api_token

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # 使用者角色定義
  enum :user_role, {
    school_admin: 0,    # 學校管理員（預設）
    super_admin: 1,     # 超級管理員
    teacher: 2          # 社團老師
  }

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
