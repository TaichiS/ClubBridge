class Api::ClubsController < ApplicationController
  before_action :set_club, only: [:update, :destroy]

  def index
    render json: Club.all
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
