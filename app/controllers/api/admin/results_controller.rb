class Api::Admin::ResultsController < ApplicationController

  # 取得班級選社結果
  def class_results
    grade = params[:grade].to_i
    class_number = params[:class].to_i
    
    return render json: { error: '請提供年級和班級參數' }, status: :bad_request if grade.zero? || class_number.zero?

    # 取得該班所有學生及其分配結果
    students_with_results = Student.where(grade: grade, class_number: class_number)
                                  .includes(:club_membership => :club)
                                  .order(:seat_number)
                                  .map do |student|
      membership = student.club_membership
      
      {
        student_id: student.id,
        seat_number: student.seat_number,
        student_number: student.student_id,
        name: student.name,
        club_name: membership&.club&.name,
        club_id: membership&.club_id,
        assignment_type: membership&.assignment_type,
        assigned_at: membership&.assigned_at,
        allocation_round: membership&.allocation_round
      }
    end

    render json: students_with_results
  end

  # 取得社團選社結果
  def club_results
    club_id = params[:club_id].to_i
    club = Club.find_by(id: club_id)
    
    return render json: { error: '找不到指定社團' }, status: :not_found unless club

    # 取得該社團所有成員
    members = ClubMembership.includes(:student)
                           .where(club: club)
                           .joins(:student)
                           .order('students.grade, students.class_number, students.seat_number')
                           .map do |membership|
      student = membership.student
      {
        student_id: student.id,
        grade: student.grade,
        class_number: student.class_number,
        class_name: student.class_name,
        seat_number: student.seat_number,
        student_number: student.student_id,
        name: student.name,
        assignment_type: membership.assignment_type,
        assigned_at: membership.assigned_at,
        allocation_round: membership.allocation_round
      }
    end

    render json: members
  end

  # 匯出班級結果為 Excel
  def export_class_results
    grade = params[:grade].to_i
    class_number = params[:class].to_i
    
    return render json: { error: '請提供年級和班級參數' }, status: :bad_request if grade.zero? || class_number.zero?

    # 取得班級名稱
    grade_name = get_grade_name(grade)
    class_name = get_class_name(class_number)
    filename = "#{grade_name}#{class_name}_選社結果.xlsx"

    # 取得資料
    students_data = Student.where(grade: grade, class_number: class_number)
                          .includes(:club_membership => :club)
                          .order(:seat_number)

    # 生成 Excel
    excel_data = generate_class_excel(students_data, grade_name, class_name)
    
    send_data excel_data, 
              filename: filename, 
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  # 匯出社團結果為 Excel
  def export_club_results
    club_id = params[:club_id].to_i
    club = Club.find_by(id: club_id)
    
    return render json: { error: '找不到指定社團' }, status: :not_found unless club

    filename = "#{club.name}_成員名單.xlsx"

    # 取得資料
    members_data = ClubMembership.includes(:student)
                                .where(club: club)
                                .joins(:student)
                                .order('students.grade, students.class_number, students.seat_number')

    # 生成 Excel
    excel_data = generate_club_excel(members_data, club)
    
    send_data excel_data, 
              filename: filename, 
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end

  private

  def get_grade_name(grade)
    case grade
    when 1 then '國一'
    when 2 then '國二' 
    when 3 then '國三'
    when 4 then '高一'
    when 5 then '高二'
    when 6 then '高三'
    else "#{grade}年級"
    end
  end

  def get_class_name(class_number)
    class_names = ['', '忠', '孝', '仁', '愛', '信', '義', '和', '平', '勇', '毅']
    class_names[class_number] || "#{class_number}班"
  end

  def generate_class_excel(students_data, grade_name, class_name)
    require 'caxlsx'
    
    package = Axlsx::Package.new
    workbook = package.workbook
    
    workbook.add_worksheet(name: "#{grade_name}#{class_name}選社結果") do |sheet|
      # 標題列
      sheet.add_row [
        '座號', '學號', '姓名', '分配社團', '分配類型', '分配時間', '分配輪次'
      ], style: workbook.styles.add_style(bg_color: 'DDDDDD', b: true)
      
      # 資料列
      students_data.each do |student|
        membership = student.club_membership
        sheet.add_row [
          student.seat_number,
          student.student_id,
          student.name,
          membership&.club&.name || '未分配',
          get_assignment_type_name(membership&.assignment_type),
          membership&.assigned_at&.strftime('%Y-%m-%d %H:%M'),
          membership&.allocation_round
        ]
      end
    end
    
    package.to_stream.read
  end

  def generate_club_excel(members_data, club)
    require 'caxlsx'
    
    package = Axlsx::Package.new
    workbook = package.workbook
    
    workbook.add_worksheet(name: "#{club.name}成員名單") do |sheet|
      # 社團資訊
      sheet.add_row ["社團名稱：#{club.name}"]
      sheet.add_row ["指導老師：#{club.teacher_name}"]
      sheet.add_row ["上課地點：#{club.location}"]
      sheet.add_row ["最大人數：#{club.max_members}"]
      sheet.add_row ["目前人數：#{members_data.count}"]
      sheet.add_row [] # 空行
      
      # 標題列
      sheet.add_row [
        '年級班級', '座號', '學號', '姓名', '分配類型', '分配時間', '分配輪次'
      ], style: workbook.styles.add_style(bg_color: 'DDDDDD', b: true)
      
      # 資料列
      members_data.each do |membership|
        student = membership.student
        sheet.add_row [
          "#{get_grade_name(student.grade)}#{student.class_name}",
          student.seat_number,
          student.student_id,
          student.name,
          get_assignment_type_name(membership.assignment_type),
          membership.assigned_at&.strftime('%Y-%m-%d %H:%M'),
          membership.allocation_round
        ]
      end
    end
    
    package.to_stream.read
  end

  def get_assignment_type_name(type)
    case type
    when 'special' then '指定分配'
    when 'normal' then '一般分配'
    when 'manual' then '手動分配'
    else '未知'
    end
  end
end