class Api::ClubSelectionsController < ApplicationController
  # 這個 controller 專門給管理員使用，只提供管理員權限相關功能
  # 公開功能與學生選社功能已移至 Api::Student::ClubSelectionsController

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

  # 指定學生入社（管理員測試用，可以指定隨機數個社團，以隨機順序分配給所有學生）
  # 本功能用於測試和演示，會覆蓋已經存在的選社記錄，必須謹慎使用。
  def assign_random_clubs
    # 使用者提供要選取多少個社團
    club_count = params[:club_count].to_i
    # 參數驗證
    if club_count <= 0
      return render json: { error: "社團數量必須大於 0" }, status: :bad_request
    end

    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能執行此操作" }, status: :unauthorized
    end

    # 選取所有社團 (acts_as_tenant 會自動限制在當前學校)
    all_clubs = Club.all

    if all_clubs.count < club_count
      return render json: { error: "可用社團數量 (#{all_clubs.count}) 少於指定數量 (#{club_count})" }, status: :bad_request
    end

    # 選取所有非特殊身份的學生 (special = 0)，不論是否已有選社記錄
    target_students = Student.where(special: 0)

    if target_students.empty?
      return render json: { error: "沒有找到可進行隨機選社的學生" }, status: :not_found
    end

    assigned_students = []
    total_selections_created = 0

    ActiveRecord::Base.transaction do
      target_students.each do |student|
        # 為每個學生隨機選取 club_count 個社團
        selected_clubs = all_clubs.sample(club_count)

        # 清除該學生之前的選社記錄（如果有的話）
        student.club_selections.destroy_all

        student_selections = []
        # 按照隨機順序創建志願序
        selected_clubs.each_with_index do |club, index|
          selection = student.club_selections.create!(
            club_id: club.id,
            preference: index + 1  # 志願序從 1 開始
          )

          student_selections << {
            club_name: club.name,
            club_number: club.club_number,
            preference: selection.preference
          }
          total_selections_created += 1
        end

        assigned_students << {
          student_name: student.name,
          student_number: student.student_id,
          grade: student.grade,
          class_name: student.class_name,
          selections: student_selections
        }

        # 記錄日誌
        Rails.logger.info "Admin random assignment - Student #{student.id} (#{student.name}) assigned #{club_count} clubs"
      end
    end

    render json: {
      message: "成功為所有學生重新隨機分配社團志願序",
      summary: {
        total_students: assigned_students.length,
        clubs_per_student: club_count,
        total_selections_created: total_selections_created,
        available_clubs: all_clubs.count
      },
      assignments: assigned_students
    }

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "隨機分配失敗：#{e.message}" }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Random club assignment error: #{e.message}"
    render json: { error: "系統錯誤，請稍後再試" }, status: :internal_server_error
  end

  # 隨機選社預覽（管理員專用）
  def random_assignment_preview
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能執行此操作" }, status: :unauthorized
    end

    # 參數驗證
    club_count = params[:club_count].to_i
    if club_count <= 0
      return render json: { error: "社團數量必須大於 0" }, status: :bad_request
    end

    # 選取所有社團 (acts_as_tenant 會自動限制在當前學校)
    all_clubs = Club.all

    if all_clubs.count < club_count
      return render json: { error: "可用社團數量 (#{all_clubs.count}) 少於指定數量 (#{club_count})" }, status: :bad_request
    end

    # 選取所有尚未選社的學生 (special = 0 且沒有選社記錄)
    students_without_selections = Student.where(special: 0)
                                        .left_joins(:club_selections)
                                        .where(club_selections: { id: nil })

    if students_without_selections.empty?
      return render json: { error: "沒有找到尚未選社的學生" }, status: :not_found
    end

    # 計算統計資訊
    students_count = students_without_selections.count
    clubs_count = all_clubs.count
    total_selections_will_create = students_count * club_count
    average_selections_per_club = total_selections_will_create.to_f / clubs_count

    render json: {
      studentsCount: students_count,
      clubsCount: clubs_count,
      totalSelectionsWillCreate: total_selections_will_create,
      averageSelectionsPerClub: average_selections_per_club.round(1),
      clubCountRequested: club_count,
      message: "預覽資訊載入成功"
    }

  rescue StandardError => e
    Rails.logger.error "Random assignment preview error: #{e.message}"
    render json: { error: "系統錯誤，請稍後再試" }, status: :internal_server_error
  end


  # 指定特殊學生入社（管理員專用）
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


  # 依照志願分發社團（管理員專用）
  def allocate_clubs
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能執行此操作" }, status: :unauthorized
    end

    # 使用 Pundit 檢查權限
    authorize ClubSelection, :allocate_clubs?

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    # 檢查是否有學生和社團
    if Student.where(school: current_school).empty?
      return render json: { error: "沒有學生資料" }, status: :bad_request
    end

    if Club.where(school: current_school).empty?
      return render json: { error: "沒有社團資料" }, status: :bad_request
    end

    # 檢查是否有選社記錄
    if ClubSelection.where(school: current_school).empty?
      return render json: { error: "沒有選社記錄" }, status: :bad_request
    end

    begin
      # 執行分發服務
      service = ClubAllocationService.new(current_school)
      result = service.allocate_clubs

      if result[:success]
        render json: {
          success: true,
          message: result[:message],
          statistics: result[:statistics],
          warnings: result[:warnings],
          total_log_entries: result[:log].length,
          detailed_log: params[:include_log] == "true" ? result[:log] : nil
        }, status: :ok
      else
        render json: {
          success: false,
          error: result[:message],
          log: result[:log]
        }, status: :unprocessable_entity
      end

    rescue StandardError => e
      Rails.logger.error "Club allocation error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render json: {
        success: false,
        error: "分發過程發生系統錯誤",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
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
