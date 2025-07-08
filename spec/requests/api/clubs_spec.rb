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
end