class Api::StatisticsController < ApplicationController
  def show
    school_id = params[:school_id]
    
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
end
