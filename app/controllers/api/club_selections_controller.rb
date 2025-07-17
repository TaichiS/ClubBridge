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

  # 指定學生入社（管理員專用）
  def assign_student
    student_id = params[:student_id]
    club_id = params[:club_id]

    # 在當前租戶（學校）範圍內查找學生和社團
    student = Student.find_by(id: student_id)
    club = Club.find_by(id: club_id)

    unless student && club
      return render json: { error: "找不到學生或社團" }, status: :not_found
    end

    # 使用 Pundit 檢查權限
    authorize student, :assign_to_club?

    # 檢查學生是否已有選社記錄
    existing_selections = ClubSelection.where(student_id: student_id)

    if existing_selections.exists?
      # 檢查是否已經指定到同一個社團
      same_club_selection = existing_selections.find_by(club_id: club_id)
      if same_club_selection
        return render json: { error: "學生已被指定到此社團" }, status: :unprocessable_entity
      end

      # 學生已有其他選社記錄，需要管理員確認是否覆蓋
      unless params[:force_override] == true
        assigned_clubs = existing_selections.includes(:club).map { |s| s.club.name }
        return render json: {
          error: "學生已有選社記錄",
          existing_clubs: assigned_clubs,
          requires_confirmation: true,
          message: "此學生已經自行選社完畢，是否要覆蓋他的志願？"
        }, status: :conflict
      end
    end

    ActiveRecord::Base.transaction do
      # 如果需要覆蓋，先刪除原有的選社記錄
      if params[:force_override] == true && existing_selections.exists?
        existing_selections.destroy_all
      end

      # 更新學生特殊狀態
      student.update!(special: 1)

      # 創建選社記錄（acts_as_tenant 會自動設置 school_id）
      selection = ClubSelection.create!(
        student_id: student_id,
        club_id: club_id,
        preference: 1
      )

      render json: {
        message: "成功指定學生入社",
        student: {
          id: student.id,
          name: student.name,
          student_number: student.student_id,  # 資料庫欄位名稱是 student_id，但儲存的是學號
          special: student.special
        },
        club: {
          id: club.id,
          name: club.name,
          number: club.club_number
        },
        selection: {
          id: selection.id,
          preference: selection.preference
        }
      }
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "指定失敗：#{e.message}" }, status: :unprocessable_entity
  rescue Pundit::NotAuthorizedError
    render json: { error: "沒有權限執行此操作" }, status: :forbidden
  end

  # 撤銷學生特殊身份（管理員專用）
  def revoke_special_status
    student_id = params[:student_id]
    student = Student.find_by(id: student_id)

    unless student
      return render json: { error: "找不到學生" }, status: :not_found
    end

    # 使用 Pundit 檢查權限
    authorize student, :revoke_special_status?

    ActiveRecord::Base.transaction do
      # 更新學生特殊狀態
      student.update!(special: 0)

      # 刪除相關選社記錄
      ClubSelection.where(student_id: student_id).destroy_all

      render json: {
        message: "成功撤銷學生特殊身份",
        student: {
          id: student.id,
          name: student.name,
          student_number: student.student_id,  # 資料庫欄位名稱是 student_id，但儲存的是學號
          special: student.special
        }
      }
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "撤銷失敗：#{e.message}" }, status: :unprocessable_entity
  rescue Pundit::NotAuthorizedError
    render json: { error: "沒有權限執行此操作" }, status: :forbidden
  end

  # 獲取特殊身份學生列表
  def special_students
    # acts_as_tenant 會自動限制在當前學校範圍內
    special_students = Student.where(special: 1)
                             .includes(:clubs)
                             .order(:grade, :class_number, :seat_number)

    # 使用 Pundit 檢查權限
    authorize special_students, :index?

    render json: special_students.map { |student|
      assigned_club = student.clubs.first
      {
        id: student.id,
        name: student.name,
        student_number: student.student_id,  # 資料庫欄位名稱是 student_id，但儲存的是學號
        grade: student.grade,
        class_number: student.class_number,
        class_name: student.class_name,
        seat_number: student.seat_number,
        special: student.special,
        assigned_club: assigned_club ? {
          id: assigned_club.id,
          name: assigned_club.name,
          number: assigned_club.club_number
        } : nil
      }
    }
  rescue Pundit::NotAuthorizedError
    render json: { error: "沒有權限查看特殊身份學生" }, status: :forbidden
  end

  # 搜尋學生（管理員專用）
  def search_students
    query = params[:query]
    return render json: [] if query.blank?

    # acts_as_tenant 會自動限制在當前學校範圍內
    students = Student.where("name LIKE ? OR student_id LIKE ?", "%#{query}%", "%#{query}%")
                     .where(special: 0)  # 只顯示非特殊身份學生
                     .limit(10)
                     .order(:grade, :class_number, :seat_number)

    # 使用 Pundit 檢查權限
    authorize students, :index?

    render json: students.map { |student|
      {
        id: student.id,
        name: student.name,
        student_number: student.student_id,  # 資料庫欄位名稱是 student_id，但儲存的是學號
        grade: student.grade,
        class_number: student.class_number,
        class_name: student.class_name,
        seat_number: student.seat_number,
        special: student.special
      }
    }
  rescue Pundit::NotAuthorizedError
    render json: { error: "沒有權限搜尋學生" }, status: :forbidden
  end

  # 其他 CRUD 操作已移至 Api::Student::ClubSelectionsController
  # 此 controller 專注於管理員查看功能
end
