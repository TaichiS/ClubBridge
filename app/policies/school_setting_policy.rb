class SchoolSettingPolicy < ApplicationPolicy
  def show?
    # 超級管理員可以查看所有學校設定
    return true if user.super_admin?
    
    # 學校管理員和老師只能查看有權限的學校設定
    user.schools.include?(record.school)
  end

  def create?
    # 超級管理員和學校管理員可以創建設定
    return true if user.super_admin?
    
    user.school_admin? && user.schools.include?(record.school)
  end

  def update?
    # 超級管理員和學校管理員可以更新設定
    return true if user.super_admin?
    
    user.school_admin? && user.schools.include?(record.school)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.joins(:school).where(schools: { id: user.school_ids })
      end
    end
  end
end
