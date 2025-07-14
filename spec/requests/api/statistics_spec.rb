require 'swagger_helper'

describe 'Statistics API', type: :request do
  let(:user) { User.create!(email: "test@example.com") }
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let!(:membership) { Membership.create!(user: user, school: school, role: :admin) }

  path '/api/schools/{school_id}/statistics' do
    get('Get school statistics') do
      tags 'Statistics'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }

        before do
          Student.create!(school: school, name: "Student 1", student_id: "S001", id_card_number: "A1")
          Student.create!(school: school, name: "Student 2", student_id: "S002", id_card_number: "A2")
          Club.create!(school: school, name: "Club 1", club_number: "C01", category: "Test", teacher_name: "T1", description: "D1", max_members: 10, location: "L1")
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['total_students']).to eq(2)
          expect(data['total_clubs']).to eq(1)
        end
      end
    end
  end
end