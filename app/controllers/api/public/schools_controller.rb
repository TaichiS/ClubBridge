# frozen_string_literal: true

class Api::Public::SchoolsController < ApplicationController
  # This controller is for public-facing school information and does not require authentication.
  skip_before_action :authenticate_user!
  skip_before_action :set_tenant

  def show
    school = School.find(params[:id])
    render json: {
      id: school.id,
      name: school.name,
      description: school.description,
      school_type: school.school_type,
      announcement: school.announcement,
      top_announcement: school.top_announcement,
      club_selection_start_time: school.club_selection_start_time,
      club_selection_end_time: school.club_selection_end_time,
      result_announcement_start_time: school.result_announcement_start_time,
      result_announcement_end_time: school.result_announcement_end_time,
      semester_schedule: school.semester_schedule,
      min_required_choices: school.min_required_choices
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'School not found' }, status: :not_found
  end
end
