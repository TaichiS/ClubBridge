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