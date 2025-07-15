class Api::Admin::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school, only: [:show, :update, :approve, :reject]

  def index
    authorize School, :index?
    @schools = policy_scope(School)
    render json: @schools
  end

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

  def pending
    authorize School, :pending?
    @pending_schools = School.pending
    render json: @pending_schools
  end

  def approve
    authorize @school
    @school.update(status: :approved)
    # You might want to trigger a notification here
    render json: { status: 'approved' }
  end

  def reject
    authorize @school
    @school.update(status: :rejected)
    # You might want to trigger a notification here
    render json: { status: 'rejected' }
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(
      :name, :school_type, :address, :website, :description,
      :contact_name, :contact_title, :contact_email, :contact_phone,
      :student_count, :club_count, :expected_start_date, :notes,
      :club_selection_start_time, :club_selection_end_time,
      :result_announcement_start_time, :result_announcement_end_time,
      :semester_schedule, :announcement, :top_announcement
    )
  end
end