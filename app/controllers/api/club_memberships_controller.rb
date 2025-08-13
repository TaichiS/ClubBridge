class Api::ClubMembershipsController < ApplicationController
  # 取得社團成員數量統計
  def count
    # 檢查管理員權限
    unless @current_user
      return render json: { error: "需要管理員身份才能查看分發記錄" }, status: :unauthorized
    end

    # 取得當前學校
    current_school = ActsAsTenant.current_tenant
    unless current_school
      return render json: { error: "無法識別當前學校" }, status: :bad_request
    end

    begin
      # 計算 ClubMembership 記錄數量
      membership_count = ClubMembership.where(school: current_school).count

      # 取得分配類型統計
      assignment_stats = ClubMembership.where(school: current_school)
                                      .group(:assignment_type)
                                      .count

      render json: {
        count: membership_count,
        assignment_statistics: assignment_stats,
        has_allocations: membership_count > 0,
        message: membership_count > 0 ? "已存在分發記錄" : "尚未進行分發"
      }

    rescue StandardError => e
      Rails.logger.error "Club membership count error: #{e.message}"
      
      render json: {
        error: "獲取分發記錄失敗",
        details: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end
end