class Api::StatisticsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:daily]
  skip_before_action :set_tenant, only: [:daily]

  def show
    school_id = params[:school_id]
    school = School.find(school_id)
    
    # 使用 School 來進行權限檢查
    authorize school, :view_statistics?
    
    # 計算各種統計資料
    total_students = Student.where(school_id: school_id).count
    total_clubs = Club.where(school_id: school_id).count
    total_selections = ClubSelection.where(school_id: school_id).count
    total_applications = ClubSelection.where(school_id: school_id).select(:student_id).distinct.count
    assigned_students = 0 # TODO: 實作分發系統後再計算實際分配數
    students_without_selection = total_students - total_applications
    clubs_with_available_spots = Club.where(school_id: school_id)
                                     .joins('LEFT JOIN club_selections ON clubs.id = club_selections.club_id')
                                     .group('clubs.id')
                                     .having('COUNT(club_selections.id) < clubs.max_members')
                                     .count.size
    assignment_completion_rate = total_students > 0 ? assigned_students.to_f / total_students : 0

    statistics = {
      total_students: total_students,
      total_clubs: total_clubs,
      total_selections: total_selections,
      total_applications: total_applications,
      assigned_students: assigned_students,
      students_without_selection: students_without_selection,
      clubs_with_available_spots: clubs_with_available_spots,
      assignment_completion_rate: assignment_completion_rate
    }

    render json: statistics
  end

  def daily
    school_id = params[:school_id]
    school = School.find(school_id)

    # 設定 tenant 以便查詢資料
    set_current_tenant(school)

    # 計算每日選社統計
    daily_stats = calculate_daily_stats(school_id)

    # 計算總體統計
    total_students = Student.where(school_id: school_id).count
    total_registrations = ClubSelection.where(school_id: school_id).select(:student_id).distinct.count
    today_registrations = ClubSelection.where(school_id: school_id)
                                       .where("DATE(created_at) = ?", Date.current)
                                       .select(:student_id)
                                       .distinct
                                       .count

    completion_rate = total_students > 0 ? (total_registrations.to_f / total_students * 100).round(2) : 0
    average_daily = daily_stats.any? ? (total_registrations.to_f / daily_stats.length).round(1) : 0

    statistics = {
      dailyStats: daily_stats,
      totalRegistrations: total_registrations,
      todayRegistrations: today_registrations,
      completionRate: completion_rate,
      averageDaily: average_daily
    }

    render json: statistics
  end

  private

  def calculate_daily_stats(school_id)
    school = School.find(school_id)
    
    # 使用學校設定的選社起始和結束時間
    start_date = school.club_selection_start_time&.to_date || Date.current - 7.days
    end_date = school.club_selection_end_time&.to_date || Date.current

    daily_data = []
    cumulative = 0
    total_students = Student.where(school_id: school_id).count

    (start_date..end_date).each do |date|
      # 計算該日新增的選社學生數（去重）
      daily_count = ClubSelection.where(school_id: school_id)
                                 .where("DATE(created_at) = ?", date)
                                 .select(:student_id)
                                 .distinct
                                 .count

      cumulative += daily_count
      completion_rate = total_students > 0 ? (cumulative.to_f / total_students * 100).round(2) : 0

      daily_data << {
        date: date.strftime("%Y-%m-%d"),
        count: daily_count,
        cumulative: cumulative,
        completionRate: completion_rate
      }
    end

    daily_data
  end
end
