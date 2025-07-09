class Api::ClubsController < ApplicationController
  before_action :set_club, only: [:update, :destroy]

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
    "社團老師 Email" => "teacher_email"
  }.freeze

  def index
    render json: Club.all
  end

  def hotness_report
    clubs_with_counts = Club
      .left_joins(:club_selections)
      .where(club_selections: { preference: 1 })
      .or(Club.where.missing(:club_selections))
      .group('clubs.id')
      .select('clubs.*, COUNT(club_selections.id) as first_choice_count')
      .order('first_choice_count DESC')

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
    
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1).map { |h| COLUMN_MAPPING[h] || h }

    (2..spreadsheet.last_row).each do |i|
      row_data = Hash[[header, spreadsheet.row(i)].transpose]
      club = school.clubs.build(row_data)
      unless club.save
        Rails.logger.error "Failed to import club: #{club.errors.full_messages.join(', ')}"
      end
    end
    render json: { message: "Import finished" }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
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
