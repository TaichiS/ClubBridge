class Api::SchoolAdmin::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school

  def show
    authorize @school
    render json: @school
  end

  def update
    authorize @school
    if @school.update(school_params)
      render json: @school
    else
      render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def school_params
    params.require(:school).permit(
      :name, :school_type, :address, :website, :description,
      :contact_name, :contact_title, :contact_email, :contact_phone,
      :student_count, :club_count, :expected_start_date, :notes,
      :club_selection_start_time, :club_selection_end_time,
      :result_announcement_start_time, :result_announcement_end_time,
      :semester_schedule
    )
  end
end