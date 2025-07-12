class Api::SchoolSettingsController < ApplicationController
  before_action :set_school
  before_action :set_setting, only: [:update]

  def show
    @setting = @school.school_setting || @school.build_school_setting
    authorize @setting
    render json: @setting
  end

  def create
    @setting = @school.build_school_setting(setting_params)
    authorize @setting
    if @setting.save
      render json: @setting, status: :created
    else
      render json: @setting.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize @setting
    if @setting.update(setting_params)
      render json: @setting
    else
      render json: @setting.errors, status: :unprocessable_entity
    end
  end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def set_setting
    @setting = @school.school_setting
    render json: { error: 'Setting not found' }, status: :not_found unless @setting
  end

  def setting_params
    params.require(:school_setting).permit(
      :welcome_message, :enrollment_start_time, :enrollment_end_time,
      :result_publication_start_time, :result_publication_end_time
    )
  end
end
