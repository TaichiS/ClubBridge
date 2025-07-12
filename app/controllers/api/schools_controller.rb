class Api::SchoolsController < ApplicationController
  def apply
    school = School.new(school_params)
    if school.save
      render json: school, status: :created
    else
      render json: school.errors, status: :unprocessable_entity
    end
  end

  private

  def school_params
    params.require(:school).permit(
      :name, :school_type, :address, :website, :description,
      :contact_name, :contact_title, :contact_email, :contact_phone,
      :student_count, :club_count, :expected_start_date, :notes,
      :applicant_name, :applicant_email
    )
  end
end
