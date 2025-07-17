class Api::ClubsController < ApplicationController
  before_action :set_club, only: [ :update, :destroy ]

  COLUMN_MAPPING = {
    "類別" => "category",
    "編號" => "club_number",
    "社團名稱" => "name",
    "指導老師" => "teacher_name",
    "簡介" => "description",
    "最大人數" => "max_members",
    "上課地點" => "location",
    "雨天地點" => "rainy_day_location",
    "備註" => "note",
    "條件一" => "condition1",
    "條件二" => "condition2",
    "條件三" => "condition3",
    "指導老師Email" => "teacher_email"
  }.freeze

  def index
    render json: Club.all
  end

  def search
    query = params[:q]
    return render json: [] if query.blank?
    
    clubs = Club.where("name LIKE ? OR club_number LIKE ?", "%#{query}%", "%#{query}%")
                .limit(10)
                .order(:club_number)
    
    render json: clubs
  end

  def hotness_report
    clubs_with_counts = Club
      .left_joins(:club_selections)
      .where(club_selections: { preference: 1 })
      .or(Club.where.missing(:club_selections))
      .group("clubs.id")
      .select("clubs.*, COUNT(club_selections.id) as first_choice_count")
      .order("first_choice_count DESC")

    render json: clubs_with_counts.as_json(methods: :first_choice_count)
  end

  def create
    club = Club.new(club_params)
    if club.save
      render json: club, status: :created
    else
      render json: club.errors, status: :unprocessable_entity
    end
  end

  def update
    if @club.update(club_params)
      render json: @club
    else
      render json: @club.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @club.destroy
    head :no_content
  end

  def import
    file = params[:file]
    school = School.find(params[:school_id])

    imported_count = 0
    error_messages = []

    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1).map { |h| COLUMN_MAPPING[h] || h }

    (2..spreadsheet.last_row).each do |i|
      row_data = Hash[[ header, spreadsheet.row(i) ].transpose]

      # 型別轉換
      if row_data["max_members"].present?
        row_data["max_members"] = row_data["max_members"].to_i
      end
      if row_data["condition1"].present?
        row_data["condition1"] = row_data["condition1"].to_i
      end
      if row_data["condition2"].present?
        row_data["condition2"] = row_data["condition2"].to_i
      end
      if row_data["condition3"].present?
        row_data["condition3"] = row_data["condition3"].to_i
      end

      # 特殊處理 club_number：純數字時轉為整數字串，否則保持原字串
      if row_data["club_number"].present?
        club_number_value = row_data["club_number"].to_s.strip
        if club_number_value.match?(/^\d+\.0*$/) # 匹配整數或整數.0的格式
          row_data["club_number"] = club_number_value.to_f.to_i.to_s
        elsif club_number_value.match?(/^\d+$/) # 匹配純整數
          row_data["club_number"] = club_number_value
        else
          row_data["club_number"] = club_number_value
        end
      end

      club = school.clubs.build(row_data)
      if club.save
        imported_count += 1
      else
        # 顯示原始資料以方便除錯
        raw_values = spreadsheet.row(i).join(" | ")
        processed_data = row_data.select { |k, v| [ "max_members", "condition1", "condition2", "club_number" ].include?(k) && v.present? }
        debug_info = processed_data.empty? ? "" : " [處理後: #{processed_data}]"
        error_messages << "第 #{i} 行 (#{raw_values})#{debug_info}：#{club.errors.full_messages.join(", ")}"
      end
    end

    render json: {
      imported: imported_count,
      errors: error_messages,
      preview: []
    }, status: :ok
  rescue => e
    render json: {
      imported: 0,
      errors: [ e.message ],
      preview: []
    }, status: :unprocessable_entity
  end

  private

  def set_club
    @club = Club.find(params[:id])
  end

  def club_params
    params.require(:club).permit(
      :category, :club_number, :name, :teacher_name, :description,
      :max_members, :location, :rainy_day_location, :note,
      :condition1, :condition2, :condition3, :teacher_email
    )
  end
end
