class Api::ClubSelectionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_tenant
  around_action :set_tenant_for_club_selection

  def create
    # Note: Student authentication is not yet implemented.
    # We are finding the student by ID from the params for now.
    student = Student.find(selection_params[:student_id])
    club_ids = selection_params[:club_ids]

    unless club_ids.is_a?(Array)
      return render json: { error: 'club_ids must be an array' }, status: :bad_request
    end

    # Ensure all submitted clubs belong to the current school
    if Club.where(id: club_ids).count != club_ids.uniq.count
      return render json: { error: 'One or more clubs are invalid or do not exist.' }, status: :not_found
    end

    selections = []
    ActiveRecord::Base.transaction do
      # 1. Delete all previous selections for this student
      student.club_selections.destroy_all

      # 2. Create new selections based on the order of the submitted array
      club_ids.each_with_index do |club_id, index|
        selections << student.club_selections.create!(
          club_id: club_id,
          preference: index + 1 # preference starts from 1
        )
      end
    end

    render json: selections, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Student not found' }, status: :not_found
  end

  private

  def set_tenant_for_club_selection
    # This is a simplified tenancy setup for the example.
    # It finds the school from the URL parameter and sets it as the current tenant.
    school = School.find_by(id: params[:school_id])
    if school
      ActsAsTenant.with_tenant(school) do
        yield
      end
    else
      render json: { error: 'School not found' }, status: :not_found
    end
  end

  def selection_params
    params.require(:club_selection).permit(:student_id, club_ids: [])
  end
end
