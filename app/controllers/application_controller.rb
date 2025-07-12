class ApplicationController < ActionController::API
  include Pundit::Authorization
  
  set_current_tenant_through_filter
  before_action :authenticate_user!
  before_action :set_tenant
  
  # Pundit 的錯誤處理
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'No token provided' }, status: :unauthorized unless token
    
    # 嘗試找到 User
    @current_user = User.find_by(api_token: token)
    
    # 如果沒有找到 User，嘗試找學生
    if @current_user.nil?
      student_data = Rails.cache.read("student_token_#{token}")
      if student_data
        @current_student = Student.find_by(id: student_data[:student_id])
        @current_school = School.find_by(id: student_data[:school_id])
      end
    end
    
    # 如果都沒有找到，返回未授權
    unless @current_user || @current_student
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end

  def set_tenant
    if params[:school_id].present?
      school = find_accessible_school(params[:school_id])
      
      if school
        set_current_tenant(school)
      else
        render json: { error: 'Forbidden' }, status: :forbidden
      end
    elsif @current_school
      # 學生登入時使用其學校
      set_current_tenant(@current_school)
    end
  end

  def find_accessible_school(school_id)
    if @current_user
      school = School.find_by(id: school_id)
      return nil unless school
      
      # 使用 Pundit 檢查權限
      authorize school, :show?
      school
    elsif @current_student
      # 學生只能訪問自己的學校
      @current_school if @current_school.id == school_id.to_i
    else
      nil
    end
  rescue Pundit::NotAuthorizedError
    nil
  end

  def user_not_authorized
    render json: { error: 'Forbidden' }, status: :forbidden
  end

  def current_user
    @current_user
  end
end
