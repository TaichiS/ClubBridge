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
    students = Student.all.includes(:school, :club_selections)
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
    
    return render json: { error: "請選擇檔案" }, status: :bad_request unless file
    
    imported_count = 0
    errors = []
    
    begin
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1).map { |h| COLUMN_MAPPING[h] || h }
      total_rows = spreadsheet.last_row - 1 # 扣除標題行

      (2..spreadsheet.last_row).each do |i|
        row_data = Hash[[header, spreadsheet.row(i)].transpose]
        
        # 處理學號格式：確保學號是字串格式（移除 .0）
        if row_data["student_id"].present?
          if row_data["student_id"].is_a?(Numeric)
            row_data["student_id"] = row_data["student_id"].to_i.to_s
          else
            student_id_str = row_data["student_id"].to_s.strip
            # 如果是類似 "105001.0" 的字串，轉換為整數再轉回字串
            if student_id_str.match?(/^\d+\.0+$/)
              row_data["student_id"] = student_id_str.to_f.to_i.to_s
            else
              row_data["student_id"] = student_id_str
            end
          end
        end
        
        # 處理其他數值欄位
        %w[grade class_number seat_number condition1 condition2 condition3].each do |field|
          if row_data[field].present? && row_data[field].is_a?(Numeric)
            row_data[field] = row_data[field].to_i
          end
        end
        
        # 處理字串欄位，移除前後空白
        %w[name class_name id_card_number].each do |field|
          if row_data[field].present?
            row_data[field] = row_data[field].to_s.strip
          end
        end
        
        
        student = Student.new(row_data)
        
        if student.save
          imported_count += 1
        else
          error_msg = "第 #{i} 行: #{student.errors.full_messages.join(', ')}"
          errors << error_msg
          Rails.logger.error "Failed to import student at row #{i}: #{error_msg}"
        end
      end
      
      render json: {
        imported: imported_count,
        errors: errors,
        preview: []
      }, status: :ok
      
    rescue => e
      Rails.logger.error "Import failed: #{e.message}"
      render json: { 
        imported: 0,
        errors: ["檔案處理失敗: #{e.message}"]
      }, status: :unprocessable_entity
    end
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    # 處理前端欄位名稱與資料庫欄位名稱的對應
    permitted_params = params.require(:student).permit(
      :grade, :class_number, :class_name, :seat_number, :student_id, :student_number,
      :name, :id_card_number, :id_number, :condition1, :condition2, :condition3
    )
    
    # 統一欄位名稱：前端可能送 student_number 或 student_id
    if permitted_params[:student_number].present?
      permitted_params[:student_id] = permitted_params[:student_number]
      permitted_params.delete(:student_number)
    end
    
    # 統一欄位名稱：前端可能送 id_number 或 id_card_number
    if permitted_params[:id_number].present?
      permitted_params[:id_card_number] = permitted_params[:id_number]
      permitted_params.delete(:id_number)
    end
    
    permitted_params
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
      has_selection: student.club_selections.exists?,
      assigned_club: nil, # 目前系統尚未實現分發功能
      created_at: student.created_at,
      updated_at: student.updated_at
    }
  end
end
