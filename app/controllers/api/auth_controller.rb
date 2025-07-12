class Api::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:google_login, :student_login]
  skip_before_action :set_tenant, only: [:google_login, :student_login, :logout, :me]

  # POST /api/auth/google
  def google_login
    google_token = params[:token]
    
    begin
      # 驗證 Google Token
      user_info = verify_google_token(google_token)
      
      # 尋找或建立使用者
      user = User.find_or_create_by(email: user_info['email']) do |u|
        u.name = user_info['name']
        u.api_token = SecureRandom.hex(32)
      end
      
      # 確保有 API Token
      user.update!(api_token: SecureRandom.hex(32)) if user.api_token.blank?
      
      schools = user.schools.map do |school|
        membership = user.memberships.find_by(school: school)
        {
          id: school.id,
          name: school.name,
          membership_role: membership&.role
        }
      end

      render json: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          type: 'user',
          user_role: user.user_role,
          schools: schools
        },
        token: user.api_token
      }
    rescue => e
      Rails.logger.error "Google login error: #{e.message}"
      render json: { error: 'Google 登入失敗' }, status: :unauthorized
    end
  end

  # POST /api/auth/student
  def student_login
    student_id = params[:student_id]
    id_number = params[:id_number]
    school_id = params[:school_id]
    
    school = School.find_by(id: school_id)
    return render json: { error: '學校不存在' }, status: :not_found unless school
    
    # 設定 tenant
    set_current_tenant(school)
    
    # 尋找學生
    student = Student.find_by(student_id: student_id, id_number: id_number)
    return render json: { error: '學號或身分證字號錯誤' }, status: :unauthorized unless student
    
    # 為學生建立臨時登入 token（儲存在 session 或 cache）
    token = SecureRandom.hex(32)
    Rails.cache.write("student_token_#{token}", { 
      student_id: student.id, 
      school_id: school.id 
    }, expires_in: 8.hours)
    
    render json: {
      student: {
        id: student.id,
        name: student.name,
        student_id: student.student_id,
        grade: student.grade,
        class_name: student.class_name,
        type: 'student'
      },
      school: {
        id: school.id,
        name: school.name
      },
      token: token
    }
  end

  # POST /api/auth/logout
  def logout
    token = request.headers['Authorization']&.split(' ')&.last
    
    if @current_user
      @current_user.update!(api_token: nil)
    elsif token
      # 清除學生 token
      Rails.cache.delete("student_token_#{token}")
    end
    
    render json: { message: '登出成功' }
  end

  # GET /api/auth/me
  def me
    if @current_user
      schools = @current_user.schools.map do |school|
        membership = @current_user.memberships.find_by(school: school)
        {
          id: school.id,
          name: school.name,
          membership_role: membership&.role
        }
      end

      render json: {
        id: @current_user.id,
        name: @current_user.name,
        email: @current_user.email,
        type: 'user',
        user_role: @current_user.user_role,
        schools: schools
      }
    elsif @current_student
      render json: {
        id: @current_student.id,
        name: @current_student.name,
        student_id: @current_student.student_id,
        grade: @current_student.grade,
        class_name: @current_student.class_name,
        type: 'student'
      }
    else
      render json: { error: 'Not authenticated' }, status: :unauthorized
    end
  end

  # GET /api/auth/validate
  def validate
    render json: { valid: (@current_user || @current_student).present? }
  end

  # POST /api/auth/refresh
  def refresh
    if @current_user
      new_token = SecureRandom.hex(32)
      @current_user.update!(api_token: new_token)
      render json: { token: new_token }
    elsif @current_student
      # 為學生更新 token
      old_token = request.headers['Authorization']&.split(' ')&.last
      new_token = SecureRandom.hex(32)
      
      if old_token
        student_data = Rails.cache.read("student_token_#{old_token}")
        if student_data
          Rails.cache.delete("student_token_#{old_token}")
          Rails.cache.write("student_token_#{new_token}", student_data, expires_in: 8.hours)
          render json: { token: new_token }
        else
          render json: { error: 'Invalid token' }, status: :unauthorized
        end
      else
        render json: { error: 'No token provided' }, status: :unauthorized
      end
    else
      render json: { error: 'Not authenticated' }, status: :unauthorized
    end
  end

  private

  def verify_google_token(token)
    require 'net/http'
    require 'json'
    
    # 使用 Google API 驗證 token
    uri = URI('https://www.googleapis.com/oauth2/v1/userinfo')
    uri.query = URI.encode_www_form(access_token: token)
    
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      JSON.parse(response.body)
    else
      raise 'Invalid Google token'
    end
  end
end