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
    params.require(:school).permit(:name)
  end
end
