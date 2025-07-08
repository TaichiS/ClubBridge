module ApiHelpers
  def auth_headers(user)
    { 'Authorization' => "Bearer #{user.api_token}" }
  end

  def create_user_with_school(role: :admin)
    user = User.create!(email: "user_#{SecureRandom.hex(4)}@example.com")
    school = School.create!(name: "School_#{SecureRandom.hex(4)}", status: :approved)
    Membership.create!(user: user, school: school, role: role)
    [user, school]
  end
end
