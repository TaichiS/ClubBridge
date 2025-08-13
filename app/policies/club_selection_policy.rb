class ClubSelectionPolicy < ApplicationPolicy
  # 只有管理員可以查看所有選社記錄
  def index?
    user_is_admin?
  end

  # 只有管理員可以執行社團分發
  def allocate_clubs?
    user_is_admin?
  end

  # 只有管理員可以隨機分配社團
  def assign_random_clubs?
    user_is_admin?
  end

  # 只有管理員可以查看隨機分配預覽
  def random_assignment_preview?
    user_is_admin?
  end

  # 只有管理員可以指定學生入社
  def assign_student?
    user_is_admin?
  end

  # 只有管理員可以搜尋學生
  def search_students?
    user_is_admin?
  end

  # 只有管理員可以查看特殊學生列表
  def special_students?
    user_is_admin?
  end

  private

  def user_is_admin?
    return false unless @user
    @user.school_admin? || @user.super_admin?
  end
end