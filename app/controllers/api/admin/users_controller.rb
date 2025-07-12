class Api::Admin::UsersController < ApplicationController
  before_action :ensure_super_admin
  before_action :set_user, only: [:show, :update, :add_school, :remove_school]

  def index
    users = User.includes(:schools, :memberships)
                .order(:created_at)
                .page(params[:page])
                .per(params[:per_page] || 20)
    
    render json: {
      users: users.map { |user| user_with_details(user) },
      meta: {
        current_page: users.current_page,
        total_pages: users.total_pages,
        total_count: users.total_count
      }
    }
  end

  def show
    render json: user_with_details(@user)
  end

  def update
    if @user.update(user_params)
      render json: user_with_details(@user)
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def add_school
    school = School.find(params[:school_id])
    membership = @user.memberships.find_or_create_by(school: school) do |m|
      m.role = params[:role] || 'admin'
    end
    
    if membership.persisted?
      render json: user_with_details(@user)
    else
      render json: { errors: membership.errors }, status: :unprocessable_entity
    end
  end

  def remove_school
    school = School.find(params[:school_id])
    membership = @user.memberships.find_by(school: school)
    
    if membership&.destroy
      render json: user_with_details(@user)
    else
      render json: { error: 'Membership not found' }, status: :not_found
    end
  end

  private

  def ensure_super_admin
    unless current_user&.super_admin?
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :user_role)
  end

  def user_with_details(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      user_role: user.user_role,
      user_role_text: user.user_role.humanize,
      created_at: user.created_at,
      updated_at: user.updated_at,
      schools: user.schools.map do |school|
        membership = user.memberships.find_by(school: school)
        {
          id: school.id,
          name: school.name,
          membership_role: membership&.role,
          created_at: membership&.created_at
        }
      end
    }
  end
end
