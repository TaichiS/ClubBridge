class SchoolPolicy < ApplicationPolicy
  def show?
    # 超級管理員可以查看所有學校
    return true if user.super_admin?
    
    # 學校管理員和老師只能查看有 membership 的學校
    user.schools.include?(record)
  end

  def update?
    # 超級管理員可以更新所有學校
    return true if user.super_admin?
    
    # 學校管理員可以更新有 membership 的學校
    user.school_admin? && user.schools.include?(record)
  end

  def manage_settings?
    # 超級管理員和學校管理員可以管理設定
    (user.super_admin? || user.school_admin?) && 
    (user.super_admin? || user.schools.include?(record))
  end

  def view_statistics?
    # 所有角色都可以查看統計（如果有權限訪問學校）
    show?
  end

  def approve?
    # 只有超級管理員可以核准學校申請
    user.super_admin?
  end

  def reject?
    # 只有超級管理員可以拒絕學校申請
    user.super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        # 超級管理員可以看到所有學校
        scope.all
      else
        # 其他角色只能看到有 membership 的學校
        user.schools
      end
    end
  end
end
