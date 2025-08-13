class Api::UnassignedStudentsController < ApplicationController
  # 取得未分配的學生清單
  def index
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能查看未分配學生" }, status: :unauthorized
    end

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    begin
      # 使用 ClubMembership 模型的方法取得未分配學生
      unassigned_students = ClubMembership.unassigned_students(current_school)

      render json: unassigned_students.map { |student|
        {
          id: student.id,
          name: student.name,
          grade: student.grade,
          class_name: student.class_name,
          class_number: student.class_number,
          seat_number: student.seat_number,
          student_id: student.student_id,
          condition1: student.condition1,
          condition2: student.condition2,
          condition3: student.condition3
        }
      }

    rescue StandardError => e
      Rails.logger.error "Get unassigned students error: #{e.message}"
      render json: {
        error: "獲取未分配學生失敗",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end

  # 取得有空位的社團清單
  def available_clubs
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能查看可用社團" }, status: :unauthorized
    end

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    begin
      # 取得所有社團並計算可用空位
      clubs_with_availability = Club.where(school: current_school).map do |club|
        current_members = ClubMembership.where(club: club, school: current_school).count
        available_spots = club.max_members - current_members

        if available_spots > 0
          {
            id: club.id,
            name: club.name,
            category: club.category,
            teacher_name: club.teacher_name,
            location: club.location,
            max_members: club.max_members,
            current_members: current_members,
            available_spots: available_spots,
            condition1: club.condition1,
            condition2: club.condition2,
            condition3: club.condition3
          }
        end
      end.compact

      render json: clubs_with_availability

    rescue StandardError => e
      Rails.logger.error "Get available clubs error: #{e.message}"
      render json: {
        error: "獲取可用社團失敗",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end

  # 手動分配學生到社團
  def manual_assignment
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能執行手動分配" }, status: :unauthorized
    end

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    student_id = params[:student_id]
    club_id = params[:club_id]

    unless student_id && club_id
      return render json: { error: "缺少必要參數" }, status: :bad_request
    end

    begin
      ActiveRecord::Base.transaction do
        # 查找學生和社團
        student = Student.find_by(id: student_id, school: current_school)
        club = Club.find_by(id: club_id, school: current_school)

        unless student && club
          return render json: { error: "找不到學生或社團" }, status: :not_found
        end

        # 檢查學生是否已被分配
        if ClubMembership.exists?(student: student, school: current_school)
          return render json: { error: "學生已被分配到其他社團" }, status: :unprocessable_entity
        end

        # 檢查社團是否還有空位
        current_members = ClubMembership.where(club: club, school: current_school).count
        if current_members >= club.max_members
          return render json: { error: "該社團已額滿" }, status: :unprocessable_entity
        end

        # 檢查學生是否符合社團條件
        unless student_meets_club_conditions?(student, club)
          return render json: { error: "學生不符合該社團的條件限制" }, status: :unprocessable_entity
        end

        # 建立分配記錄
        membership = ClubMembership.assign_student_to_club(
          student,
          club,
          'manual'  # 手動分配類型
        )

        render json: {
          success: true,
          message: "成功分配學生到社團",
          student: {
            id: student.id,
            name: student.name,
            student_id: student.student_id
          },
          club: {
            id: club.id,
            name: club.name,
            category: club.category
          },
          membership: {
            id: membership.id,
            assigned_at: membership.assigned_at,
            assignment_type: membership.assignment_type
          }
        }
      end

    rescue ActiveRecord::RecordNotFound
      render json: { error: "找不到指定的學生或社團" }, status: :not_found
    rescue StandardError => e
      Rails.logger.error "Manual assignment error: #{e.message}"
      render json: {
        error: "手動分配失敗",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end

  # 批量分配學生到社團
  def bulk_assignment
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能執行批量分配" }, status: :unauthorized
    end

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    student_ids = params[:student_ids]
    club_id = params[:club_id]

    unless student_ids.is_a?(Array) && club_id
      return render json: { error: "參數格式錯誤" }, status: :bad_request
    end

    begin
      ActiveRecord::Base.transaction do
        club = Club.find_by(id: club_id, school: current_school)
        unless club
          return render json: { error: "找不到指定社團" }, status: :not_found
        end

        # 檢查社團可用空位
        current_members = ClubMembership.where(club: club, school: current_school).count
        available_spots = club.max_members - current_members

        if student_ids.length > available_spots
          return render json: { 
            error: "分配人數超過社團剩餘空位",
            available_spots: available_spots,
            requested_count: student_ids.length
          }, status: :unprocessable_entity
        end

        assigned_count = 0
        failed_assignments = []

        student_ids.each do |student_id|
          begin
            student = Student.find_by(id: student_id, school: current_school)
            
            unless student
              failed_assignments << { student_id: student_id, reason: "找不到學生" }
              next
            end

            # 檢查學生是否已被分配
            if ClubMembership.exists?(student: student, school: current_school)
              failed_assignments << { student_id: student_id, reason: "學生已被分配" }
              next
            end

            # 檢查條件限制
            unless student_meets_club_conditions?(student, club)
              failed_assignments << { student_id: student_id, reason: "不符合社團條件" }
              next
            end

            # 建立分配記錄
            ClubMembership.assign_student_to_club(student, club, 'manual')
            assigned_count += 1

          rescue => e
            failed_assignments << { student_id: student_id, reason: e.message }
          end
        end

        render json: {
          success: true,
          message: "批量分配完成",
          assigned_count: assigned_count,
          failed_assignments: failed_assignments,
          club: {
            id: club.id,
            name: club.name,
            remaining_spots: club.max_members - ClubMembership.where(club: club, school: current_school).count
          }
        }
      end

    rescue ActiveRecord::RecordNotFound
      render json: { error: "找不到指定社團" }, status: :not_found
    rescue StandardError => e
      Rails.logger.error "Bulk assignment error: #{e.message}"
      render json: {
        error: "批量分配失敗",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end

  # 取得分配統計
  def statistics
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能查看統計" }, status: :unauthorized
    end

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    begin
      total_students = Student.where(school: current_school).count
      assigned_students = ClubMembership.where(school: current_school).count
      unassigned_students = total_students - assigned_students

      assignment_by_type = ClubMembership.assignment_statistics(current_school)

      render json: {
        total_students: total_students,
        assigned_students: assigned_students,
        unassigned_students: unassigned_students,
        assignment_by_type: assignment_by_type,
        clubs_with_space: Club.where(school: current_school).select { |club|
          current_members = ClubMembership.where(club: club, school: current_school).count
          current_members < club.max_members
        }.count
      }

    rescue StandardError => e
      Rails.logger.error "Assignment statistics error: #{e.message}"
      render json: {
        error: "獲取統計資料失敗",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end

  private

  # 檢查學生是否符合社團條件
  def student_meets_club_conditions?(student, club)
    # 檢查條件1（通常是性別）
    return false if club.condition1 && club.condition1 != 0 && student.condition1 != club.condition1
    
    # 檢查條件2（通常是年級/學制）
    return false if club.condition2 && club.condition2 != 0 && student.condition2 != club.condition2
    
    # 檢查條件3（客製條件）
    return false if club.condition3 && club.condition3 != 0 && student.condition3 != club.condition3
    
    true
  end
end