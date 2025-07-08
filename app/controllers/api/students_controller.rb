class Api::StudentsController < ApplicationController
  before_action :set_student, only: [:update, :destroy]

  def index
    render json: Student.all
  end

  def create
    student = Student.new(student_params)
    if student.save
      render json: student, status: :created
    else
      render json: student.errors, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      render json: @student
    else
      render json: @student.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    head :no_content
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(
      :grade, :class_number, :class_name, :seat_number, :student_id,
      :name, :id_card_number, :condition1, :condition2, :condition3
    )
  end
end
