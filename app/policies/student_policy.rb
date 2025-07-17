class StudentPolicy < ApplicationPolicy
  def index?
    # 超級管理員可以查看所有學生
    return true if user.super_admin?
    
    # 學校管理員和老師只能查看自己學校的學生
    user.school_admin? || user.teacher?
  end

  def show?
    # 超級管理員可以查看所有學生
    return true if user.super_admin?
    
    # 學校管理員和老師只能查看自己學校的學生
    (user.school_admin? || user.teacher?) && user.schools.include?(record.school)
  end

  def update?
    # 超級管理員可以更新所有學生
    return true if user.super_admin?
    
    # 學校管理員可以更新自己學校的學生
    user.school_admin? && user.schools.include?(record.school)
  end

  def assign_to_club?
    # 只有超級管理員和學校管理員可以指定學生入社
    return true if user.super_admin?
    
    # 學校管理員只能指定自己學校的學生
    user.school_admin? && user.schools.include?(record.school)
  end

  def revoke_special_status?
    # 只有超級管理員和學校管理員可以撤銷特殊身份
    return true if user.super_admin?
    
    # 學校管理員只能撤銷自己學校學生的特殊身份
    user.school_admin? && user.schools.include?(record.school)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        # 超級管理員可以看到所有學生（但仍受 acts_as_tenant 限制）
        scope.all
      else
        # 其他角色只能看到自己學校的學生
        scope.joins(:school).where(schools: { id: user.schools.pluck(:id) })
      end
    end
  end
end