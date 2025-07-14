# frozen_string_literal: true

class Api::Public::SchoolsController < ApplicationController
  # This controller is for public-facing school information and does not require authentication.

  def show
    school = School.find(params[:id])
    render json: {
      id: school.id,
      name: school.name,
      description: school.description,
      school_type: school.school_type
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'School not found' }, status: :not_found
  end
end
