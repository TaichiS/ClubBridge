class Api::Public::ClubsController < ApplicationController
  # This controller is for public-facing club information and does not require authentication.
  skip_before_action :authenticate_user!
  skip_before_action :set_tenant
  
  def index
    school = School.find(params[:school_id])
    clubs = school.clubs
    render json: clubs
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'School not found' }, status: :not_found
  end
  
  def categories
    school = School.find(params[:school_id])
    categories = school.clubs.distinct.pluck(:category).compact.sort
    
    # 計算每個類別的社團數量
    category_counts = school.clubs.group(:category).count
    
    categories_with_counts = categories.map do |category|
      {
        name: category,
        count: category_counts[category] || 0,
        icon: get_category_icon(category),
        color: get_category_color(category)
      }
    end
    
    render json: categories_with_counts
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'School not found' }, status: :not_found
  end
  
  def popular
    school = School.find(params[:school_id])
    
    # 使用 SQL 查詢來計算每個社團的第一志願人數
    clubs_with_stats = school.clubs
      .joins('LEFT JOIN club_selections ON clubs.id = club_selections.club_id AND club_selections.preference = 1')
      .select('clubs.*, COUNT(club_selections.id) as first_choice_count')
      .group('clubs.id')
      .having('COUNT(club_selections.id) > clubs.max_members')
      .order('first_choice_count DESC')
    
    # 同時取得所有社團的選社統計
    all_clubs_stats = school.clubs
      .joins('LEFT JOIN club_selections ON clubs.id = club_selections.club_id AND club_selections.preference = 1')
      .select('clubs.*, COUNT(club_selections.id) as first_choice_count')
      .group('clubs.id')
      .order('first_choice_count DESC')
    
    popular_clubs = clubs_with_stats.map do |club|
      {
        id: club.id,
        club_number: club.club_number,
        name: club.name,
        category: club.category,
        teacher_name: club.teacher_name,
        description: club.description,
        location: club.location,
        max_members: club.max_members,
        first_choice_count: club.first_choice_count,
        oversubscribed_by: club.first_choice_count - club.max_members,
        is_popular: true
      }
    end
    
    all_clubs_data = all_clubs_stats.map do |club|
      is_popular = club.first_choice_count > club.max_members
      
      {
        id: club.id,
        club_number: club.club_number,
        name: club.name,
        category: club.category,
        teacher_name: club.teacher_name,
        description: club.description,
        location: club.location,
        max_members: club.max_members,
        first_choice_count: club.first_choice_count,
        oversubscribed_by: is_popular ? club.first_choice_count - club.max_members : 0,
        is_popular: is_popular
      }
    end
    
    render json: {
      popular_clubs: popular_clubs,
      all_clubs: all_clubs_data,
      total_popular_clubs: popular_clubs.length
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'School not found' }, status: :not_found
  end
  
  private
  
  def get_category_icon(category)
    case category
    when /體育|運動|球類|武術|舞蹈/
      '⚽'
    when /藝術|美術|音樂|戲劇|表演/
      '🎨'
    when /學術|科學|數學|程式|電腦|資訊/
      '🔬'
    when /服務|志工|公益|環保/
      '🤝'
    when /技能|手作|烹飪|園藝/
      '💻'
    when /音樂|樂器|合唱|樂團/
      '🎵'
    when /語言|英文|日文|韓文/
      '🗣️'
    else
      '🌟'
    end
  end
  
  def get_category_color(category)
    case category
    when /體育|運動|球類|武術|舞蹈/
      'bg-gradient-to-r from-green-500 to-blue-500'
    when /藝術|美術|音樂|戲劇|表演/
      'bg-gradient-to-r from-purple-500 to-pink-500'
    when /學術|科學|數學|程式|電腦|資訊/
      'bg-gradient-to-r from-blue-500 to-purple-600'
    when /服務|志工|公益|環保/
      'bg-gradient-to-r from-orange-500 to-red-500'
    when /技能|手作|烹飪|園藝/
      'bg-gradient-to-r from-teal-500 to-cyan-500'
    when /音樂|樂器|合唱|樂團/
      'bg-gradient-to-r from-indigo-500 to-purple-600'
    when /語言|英文|日文|韓文/
      'bg-gradient-to-r from-pink-500 to-rose-500'
    else
      'bg-gradient-to-r from-yellow-500 to-orange-500'
    end
  end
end