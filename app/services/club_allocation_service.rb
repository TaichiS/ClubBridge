class ClubAllocationService
  attr_reader :school, :allocation_log

  def initialize(school)
    @school = school
    @allocation_log = []
    @max_rounds = 10  # 防止無窮迴圈
  end

  # 執行完整的分發流程
  def allocate_clubs
    ActiveRecord::Base.transaction do
      log_info "開始社團分發流程"
      
      # 階段一：分發前準備
      prepare_allocation
      
      # 階段二：特殊學生優先分發
      allocate_special_students
      
      # 階段三：一般學生多輪分發
      allocate_normal_students
      
      # 階段四：收尾與驗證
      finalize_allocation
      
      log_info "社團分發流程完成"
      
      {
        success: true,
        message: "分發完成",
        statistics: generate_statistics,
        warnings: extract_warnings,
        log: @allocation_log
      }
    end
  rescue StandardError => e
    log_error "分發過程發生錯誤: #{e.message}"
    {
      success: false,
      message: "分發失敗: #{e.message}",
      log: @allocation_log
    }
  end

  private

  # 階段一：分發前準備
  def prepare_allocation
    log_info "==== 階段一：分發前準備 ===="
    
    # 清空舊的分配結果
    ClubMembership.clear_school_assignments(@school)
    log_info "清空舊的分配記錄"
    
    # 複製選社志願到工作區
    ClubAllocation.copy_from_club_selections(@school)
    log_info "複製選社志願到分配工作區"
    
    # 檢查社團狀態
    validate_clubs
    
    log_info "分發前準備完成"
  end

  # 階段二：特殊學生優先分發
  def allocate_special_students
    log_info "==== 階段二：特殊學生優先分發 ===="
    
    special_students = Student.where(school: @school, special: 1)
    log_info "找到 #{special_students.count} 位特殊學生"
    
    return if special_students.empty?
    
    special_students.find_each do |student|
      first_preference = ClubAllocation.where(
        student: student, 
        school: @school, 
        preference: 1
      ).first
      
      next unless first_preference
      
      club = first_preference.club
      
      # 檢查條件限制
      unless first_preference.student_meets_club_conditions?
        log_warning "特殊學生 #{student.name} 不符合 #{club.name} 的條件限制"
        next
      end
      
      # 直接分配，不受人數限制
      ClubMembership.assign_student_to_club(
        student, 
        club, 
        'special'
      )
      
      # 從工作區移除該學生的所有志願
      ClubAllocation.where(student: student, school: @school).delete_all
      
      log_info "特殊學生 #{student.name} 分配到 #{club.name}"
      
      # 檢查特殊學生警告
      check_special_student_warning(club)
    end
    
    log_info "特殊學生分發完成"
  end

  # 階段三：一般學生多輪分發
  def allocate_normal_students
    log_info "==== 階段三：一般學生多輪分發 ===="
    
    current_round = 1
    
    while current_round <= @max_rounds
      log_info "--- 第 #{current_round} 輪分發 ---"
      
      allocated_in_round = process_allocation_round(current_round)
      
      if allocated_in_round == 0
        log_info "本輪沒有學生被分配，結束分發"
        break
      end
      
      # 檢查終止條件
      if allocation_should_terminate?
        log_info "達到終止條件，結束分發"
        break
      end
      
      current_round += 1
    end
    
    if current_round > @max_rounds
      log_warning "達到最大分發輪次限制 (#{@max_rounds})"
    end
    
    log_info "一般學生分發完成"
  end

  # 處理單輪分發
  def process_allocation_round(round_number)
    allocated_count = 0
    filled_clubs = []
    
    # 取得所有仍有空位的社團
    available_clubs = get_available_clubs
    
    available_clubs.each do |club|
      remaining_spots = calculate_remaining_spots(club)
      next if remaining_spots <= 0
      
      # 取得該社團在當前偏好序的申請者（固定為第一志願，因為每輪後會重新整理）
      applicants = get_qualified_applicants(club, 1)
      
      if applicants.empty?
        next
      end
      
      # 分配學生
      students_to_assign = if applicants.count <= remaining_spots
                          applicants.to_a
                        else
                          applicants.sample(remaining_spots)  # 隨機選取
                        end
      
      students_to_assign.each do |allocation|
        ClubMembership.assign_student_to_club(
          allocation.student,
          club,
          'normal',
          round_number
        )
        
        # 從工作區移除該學生的所有志願
        ClubAllocation.where(student: allocation.student, school: @school).delete_all
        
        allocated_count += 1
        log_info "學生 #{allocation.student.name} 分配到 #{club.name} (第 #{round_number} 志願)"
      end
      
      # 檢查社團是否已滿
      if calculate_remaining_spots(club) <= 0
        filled_clubs << club
      end
    end
    
    # 移除滿額社團並重新整理志願序
    filled_clubs.each do |club|
      ClubAllocation.remove_club_and_reorder(club, @school)
      log_info "#{club.name} 已滿額，從志願清單中移除"
    end
    
    allocated_count
  end

  # 階段四：收尾與驗證
  def finalize_allocation
    log_info "==== 階段四：收尾與驗證 ===="
    
    # 產生未分配學生清單
    unassigned_students = ClubMembership.unassigned_students(@school)
    if unassigned_students.any?
      log_warning "有 #{unassigned_students.count} 位學生未被分配到社團"
      unassigned_students.limit(10).each do |student|
        log_warning "未分配學生: #{student.name} (#{student.student_id})"
      end
    end
    
    # 驗證分配結果
    validate_allocation_results
    
    log_info "分發流程驗證完成"
  end

  # 檢查特殊學生警告
  def check_special_student_warning(club)
    special_count = ClubMembership.where(
      club: club, 
      school: @school, 
      assignment_type: 'special'
    ).count
    
    if special_count > club.max_members * 0.5
      log_warning "警告：#{club.name} 的特殊學生人數 (#{special_count}) 超過總容量的50% (#{club.max_members})"
    end
  end

  # 取得有空位的社團
  def get_available_clubs
    Club.where(school: @school).select do |club|
      calculate_remaining_spots(club) > 0
    end
  end

  # 計算社團剩餘名額
  def calculate_remaining_spots(club)
    current_members = ClubMembership.where(club: club, school: @school).count
    club.max_members - current_members
  end

  # 取得符合條件的申請者
  def get_qualified_applicants(club, preference_number)
    ClubAllocation.includes(:student)
                  .where(club: club, school: @school, preference: preference_number)
                  .select(&:student_meets_club_conditions?)
  end

  # 檢查是否應該終止分發
  def allocation_should_terminate?
    # 沒有學生等待分配
    return true if ClubAllocation.where(school: @school).empty?
    
    # 沒有社團有空位
    available_clubs = get_available_clubs
    return true if available_clubs.empty?
    
    false
  end

  # 驗證社團狀態
  def validate_clubs
    clubs = Club.where(school: @school)
    
    if clubs.empty?
      raise "沒有可用的社團"
    end
    
    clubs.each do |club|
      if club.max_members <= 0
        log_warning "社團 #{club.name} 的最大人數設定無效: #{club.max_members}"
      end
    end
  end

  # 驗證分配結果
  def validate_allocation_results
    # 檢查重複分配
    duplicate_assignments = ClubMembership.where(school: @school)
                                         .group(:student_id)
                                         .having('COUNT(*) > 1')
    
    if duplicate_assignments.any?
      log_error "發現重複分配的學生"
    end
    
    # 檢查社團人數超限（特殊學生除外）
    Club.where(school: @school).each do |club|
      total_members = ClubMembership.where(club: club, school: @school).count
      normal_members = ClubMembership.where(
        club: club, 
        school: @school, 
        assignment_type: 'normal'
      ).count
      
      if normal_members > club.max_members
        log_error "社團 #{club.name} 的一般學生人數超過限制"
      end
      
      if total_members > club.max_members
        log_info "社團 #{club.name} 總人數 #{total_members} (含特殊學生)"
      end
    end
  end

  # 產生統計資訊
  def generate_statistics
    {
      total_students: Student.where(school: @school).count,
      assigned_students: ClubMembership.where(school: @school).count,
      unassigned_students: ClubMembership.unassigned_students(@school).count,
      assignment_by_type: ClubMembership.assignment_statistics(@school),
      club_member_counts: ClubMembership.club_member_counts(@school)
    }
  end

  # 提取警告訊息
  def extract_warnings
    @allocation_log.select { |entry| entry[:level] == 'WARNING' }
                   .map { |entry| entry[:message] }
  end

  # 日誌方法
  def log_info(message)
    @allocation_log << {
      timestamp: Time.current,
      level: 'INFO',
      message: message
    }
  end

  def log_warning(message)
    @allocation_log << {
      timestamp: Time.current,
      level: 'WARNING', 
      message: message
    }
  end

  def log_error(message)
    @allocation_log << {
      timestamp: Time.current,
      level: 'ERROR',
      message: message
    }
  end
end