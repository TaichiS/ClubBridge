class ApplicationController < ActionController::API
  set_current_tenant_through_filter
  before_action :set_tenant

  private

  def set_tenant
    if params[:school_id].present?
      school = School.find(params[:school_id])
      set_current_tenant(school)
    end
  end
end
