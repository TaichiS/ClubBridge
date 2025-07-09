require 'swagger_helper'

describe 'Clubs API', type: :request do
  let(:user) { User.create!(email: "test@example.com") }
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let!(:membership) { Membership.create!(user: user, school: school, role: :admin) }

  path '/api/schools/{school_id}/clubs' do
    get('List clubs') do
      tags 'Clubs'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        before { Club.create!(name: "Test Club", school: school, club_number: "C001", category: "Test", teacher_name: "Test Teacher", description: "Test", max_members: 10, location: "Test") }
        run_test!
      end
    end

    post('Create a club') do
      tags 'Clubs'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :club, in: :body, schema: {
        type: :object,
        properties: {
          club: {
            type: :object,
            properties: {
              name: { type: :string },
              club_number: { type: :string },
              category: { type: :string },
              teacher_name: { type: :string },
              description: { type: :string },
              max_members: { type: :integer },
              location: { type: :string }
            },
            required: ['name', 'club_number', 'category', 'teacher_name', 'description', 'max_members', 'location']
          }
        }
      }

      response(201, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:club) { { club: { name: "New Club", club_number: "C002", category: "New", teacher_name: "New Teacher", description: "New", max_members: 15, location: "New" } } }
        run_test!
      end
    end
  end

  path '/api/schools/{school_id}/clubs/import' do
    post('Import clubs from Excel') do
      tags 'Clubs'
      consumes 'multipart/form-data'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :file, in: :formData, type: :file, required: true

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:file) { fixture_file_upload('test/fixtures/files/clubs.xlsx') }
        run_test!
      end
    end
  end

  path '/api/schools/{school_id}/clubs/hotness_report' do
    get('Get club hotness report') do
      tags 'Clubs'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }

        before do
          # Create clubs
          club1 = Club.create!(school: school, name: "Basketball Club", club_number: "B01", category: "Sports", teacher_name: "Coach A", description: "...", max_members: 20, location: "Gym")
          club2 = Club.create!(school: school, name: "Art Club", club_number: "A01", category: "Arts", teacher_name: "Teacher B", description: "...", max_members: 15, location: "Art Room")
          club3 = Club.create!(school: school, name: "Chess Club", club_number: "C01", category: "Strategy", teacher_name: "Mr. C", description: "...", max_members: 30, location: "Library")

          # Create students
          s1 = Student.create!(school: school, name: "Student 1", student_id: "S001", id_card_number: "A1")
          s2 = Student.create!(school: school, name: "Student 2", student_id: "S002", id_card_number: "A2")
          s3 = Student.create!(school: school, name: "Student 3", student_id: "S003", id_card_number: "A3")
          s4 = Student.create!(school: school, name: "Student 4", student_id: "S004", id_card_number: "A4")

          # Create selections
          # Basketball Club: 2 first choices
          ClubSelection.create!(school: school, student: s1, club: club1, preference: 1)
          ClubSelection.create!(school: school, student: s2, club: club1, preference: 1)
          # Art Club: 1 first choice
          ClubSelection.create!(school: school, student: s3, club: club2, preference: 1)
          # Basketball as second choice for s3
          ClubSelection.create!(school: school, student: s3, club: club1, preference: 2)
          # Chess Club: 0 first choices
          ClubSelection.create!(school: school, student: s4, club: club2, preference: 2)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(3)
          
          basketball_data = data.find { |c| c['name'] == "Basketball Club" }
          art_data = data.find { |c| c['name'] == "Art Club" }
          chess_data = data.find { |c| c['name'] == "Chess Club" }

          expect(basketball_data['first_choice_count']).to eq(2)
          expect(art_data['first_choice_count']).to eq(1)
          expect(chess_data['first_choice_count']).to eq(0)
        end
      end
    end
  end
end
