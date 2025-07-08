class Api::Admin::SchoolsController < ApplicationController
  def pending
    schools = School.pending
    render json: schools
  end

  def approve
    school = School.find(params[:id])
    if school.approved!
      render json: school
    else
      render json: school.errors, status: :unprocessable_entity
    end
  end
end
