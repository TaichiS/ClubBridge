class Api::Admin::SchoolsController < ApplicationController
  def show
    school = School.find(params[:id])
    render json: school
  end

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

  def reject
    school = School.find(params[:id])
    reject_reason = params[:reason]
    
    school.update!(
      status: :rejected,
      rejection_reason: reject_reason
    )
    
    render json: school
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
