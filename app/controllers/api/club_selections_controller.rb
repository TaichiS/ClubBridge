class Api::ClubSelectionsController < ApplicationController
  # 這個 controller 專門給管理員使用，只提供查看功能
  # 學生選社功能已移至 Api::Student::ClubSelectionsController

  # 取得選社記錄（管理員專用）
  def index
    unless @current_user
      return render json: { error: "需要管理員身份才能查看選社記錄" }, status: :unauthorized
    end

    student_id = params[:student_id]
    if student_id.present?
      student = Student.find(student_id)
      selections = student.club_selections.includes(:club).order(:preference)
    else
      selections = ClubSelection.includes(:student, :club).order(:preference)
    end

    render json: selections.map { |selection|
      {
        id: selection.id,
        student_id: selection.student_id,
        student_name: selection.student.name,
        club_id: selection.club_id,
        club_name: selection.club.name,
        preference: selection.preference,
        created_at: selection.created_at,
        updated_at: selection.updated_at
      }
    }
  end

  # 其他 CRUD 操作已移至 Api::Student::ClubSelectionsController
  # 此 controller 專注於管理員查看功能
end
