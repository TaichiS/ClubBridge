class Api::StudentsController < ApplicationController
  before_action :set_student, only: [:update, :destroy]

  COLUMN_MAPPING = {
    "年級" => "grade",
    "班級（數字）" => "class_number",
    "班級（中文）" => "class_name",
    "座號" => "seat_number",
    "學號" => "student_id",
    "姓名" => "name",
    "身分證字號" => "id_card_number",
    "條件一" => "condition1",
    "條件二" => "condition2",
    "條件三" => "condition3"
  }.freeze

  def index
    students = Student.all.includes(:school)
    render json: students.map { |student| student_json(student) }
  end

  def create
    student = Student.new(student_params)
    if student.save
      render json: student_json(student), status: :created
    else
      render json: { errors: student.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      render json: student_json(@student)
    else
      render json: { errors: @student.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    head :no_content
  end

  def import
    file = params[:file]
    # TODO: Add file validation

    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1).map { |h| COLUMN_MAPPING[h] || h }

    (2..spreadsheet.last_row).each do |i|
      row_data = Hash[[header, spreadsheet.row(i)].transpose]
      student = Student.new(row_data)
      unless student.save
        # Log error or handle it
        Rails.logger.error "Failed to import student: #{student.errors.full_messages.join(', ')}"
        # Optionally, collect errors and return them
      end
    end
    render json: { message: "Import finished" }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
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

  def student_json(student)
    {
      id: student.id,
      student_id: student.student_id,
      name: student.name,
      grade: student.grade,
      class_number: student.class_number,
      class_name: student.class_name,
      seat_number: student.seat_number,
      id_number: student.id_card_number,
      condition1: student.condition1,
      condition2: student.condition2,
      condition3: student.condition3,
      school_id: student.school_id,
      created_at: student.created_at,
      updated_at: student.updated_at
    }
  end
end
