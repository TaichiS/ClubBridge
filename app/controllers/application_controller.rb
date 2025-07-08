class ApplicationController < ActionController::API
  set_current_tenant_through_filter
  before_action :authenticate_user!
  before_action :set_tenant

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = User.find_by(api_token: token)
    render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
  end

  def set_tenant
    if params[:school_id].present?
      school = if @current_user.super_admin?
                 School.find_by(id: params[:school_id])
               else
                 @current_user.schools.find_by(id: params[:school_id])
               end

      if school
        set_current_tenant(school)
      else
        render json: { error: 'Forbidden' }, status: :forbidden
      end
    end
  end
end
