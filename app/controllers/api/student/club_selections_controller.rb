class Api::Student::ClubSelectionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_tenant
  around_action :set_tenant_for_student
  before_action :authenticate_student!
  before_action :check_selection_period, only: [:create, :update]

  # 取得學生自己的選社記錄
  def index
    selections = @current_student.club_selections.includes(:club).order(:preference)
    
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

  # 提交志願序
  def create
    club_ids = selection_params[:club_choices]

    unless club_ids.is_a?(Array)
      return render json: { error: "club_choices must be an array" }, status: :bad_request
    end

    # 檢查最少志願數
    min_required = current_tenant.min_required_choices || 3
    if club_ids.length < min_required
      return render json: {
        error: "至少需要選擇 #{min_required} 個志願"
      }, status: :bad_request
    end

    # 檢查是否有重複的社團
    if club_ids.uniq.length != club_ids.length
      return render json: { error: "不能選擇重複的社團" }, status: :bad_request
    end

    # 確保所有提交的社團都屬於當前學校
    valid_clubs = Club.where(id: club_ids)
    if valid_clubs.count != club_ids.length
      return render json: { error: "選擇的社團無效或不存在" }, status: :not_found
    end

    # 檢查社團是否有名額限制
    invalid_clubs = valid_clubs.select { |club| club.max_members <= (club.current_members || 0) }
    if invalid_clubs.any?
      return render json: {
        error: "以下社團已滿額：#{invalid_clubs.map(&:name).join(', ')}"
      }, status: :bad_request
    end

    selections = []
    ActiveRecord::Base.transaction do
      # 1. 刪除該學生之前的所有選社記錄
      @current_student.club_selections.destroy_all

      # 2. 根據提交的順序創建新的選社記錄
      club_ids.each_with_index do |club_id, index|
        selections << @current_student.club_selections.create!(
          club_id: club_id,
          preference: index + 1 # preference starts from 1
        )
      end
    end

    # 記錄提交時間
    Rails.logger.info "Student #{@current_student.id} (#{@current_student.name}) submitted club selections: #{club_ids}"

    render json: {
      message: "志願提交成功",
      selections: selections.map { |selection|
        {
          id: selection.id,
          club_id: selection.club_id,
          club_name: selection.club.name,
          preference: selection.preference
        }
      }
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "學生不存在" }, status: :not_found
  end

  # 更新志願序（重新排序）
  def update
    club_ids = selection_params[:club_choices]

    unless club_ids.is_a?(Array)
      return render json: { error: "club_choices must be an array" }, status: :bad_request
    end

    # 檢查最少志願數
    min_required = current_tenant.min_required_choices || 3
    if club_ids.length < min_required
      return render json: {
        error: "至少需要選擇 #{min_required} 個志願"
      }, status: :bad_request
    end

    ActiveRecord::Base.transaction do
      # 刪除舊的選社記錄
      @current_student.club_selections.destroy_all

      # 創建新的選社記錄
      club_ids.each_with_index do |club_id, index|
        @current_student.club_selections.create!(
          club_id: club_id,
          preference: index + 1
        )
      end
    end

    render json: { message: "志願更新成功" }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # 刪除志願序
  def destroy
    @current_student.club_selections.destroy_all
    render json: { message: "志願已清除" }, status: :ok
  end

  private

  # 設定學生租戶
  def set_tenant_for_student
    school = School.find_by(id: params[:school_id])
    if school
      ActsAsTenant.with_tenant(school) do
        yield
      end
    else
      render json: { error: "School not found" }, status: :not_found
    end
  end

  # 學生身份驗證
  def authenticate_student!
    token = request.headers["Authorization"]&.split(" ")&.last
    return render json: { error: "No token provided" }, status: :unauthorized unless token

    # 從快取中取得學生資料
    student_data = Rails.cache.read("student_token_#{token}")
    if student_data
      @current_student = Student.find_by(id: student_data[:student_id])
      @current_school = School.find_by(id: student_data[:school_id])
    end

    unless @current_student
      render json: { error: "學生身份驗證失敗" }, status: :unauthorized
    end
  end

  # 檢查選社期間
  def check_selection_period
    school = current_tenant

    # 如果沒有設定選社時間，允許選社
    return unless school.club_selection_start_time && school.club_selection_end_time

    now = Time.current
    start_time = school.club_selection_start_time
    end_time = school.club_selection_end_time

    if now < start_time
      render json: {
        error: "選社尚未開始，開始時間：#{start_time.strftime('%Y-%m-%d %H:%M')}"
      }, status: :forbidden
    elsif now > end_time
      render json: {
        error: "選社已結束，結束時間：#{end_time.strftime('%Y-%m-%d %H:%M')}"
      }, status: :forbidden
    end
  end

  def selection_params
    params.permit(:student_id, club_choices: [])
  end
end