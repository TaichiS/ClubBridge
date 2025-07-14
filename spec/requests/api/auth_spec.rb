require 'swagger_helper'

describe 'Auth API', type: :request do
  path '/api/auth/google' do
    post('Google Login') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          token: { type: :string, description: 'Google ID Token' }
        },
        required: ['token']
      }

      response(200, 'successful') do
        let(:params) { { token: 'fake_google_token' } }
        # This is a mock response. In a real test, you would mock the Google API call.
        run_test!
      end

      response(401, 'unauthorized') do
        let(:params) { { token: 'invalid_token' } }
        run_test!
      end
    end
  end

  path '/api/auth/student' do
    post('Student Login') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          school_id: { type: :string },
          student_id: { type: :string },
          id_card_number: { type: :string }
        },
        required: ['school_id', 'student_id', 'id_card_number']
      }

      response(200, 'successful') do
        let(:school) { School.create!(name: "Test School", status: :approved) }
        let(:student) { Student.create!(school: school, student_id: "S001", id_card_number: "A123456789", name: "Test Student") }
        let(:params) { { school_id: school.id, student_id: student.student_id, id_card_number: student.id_card_number } }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:params) { { school_id: '1', student_id: 'invalid', id_card_number: 'invalid' } }
        run_test!
      end
    end
  end

  path '/api/auth/logout' do
    post('Logout') do
      tags 'Auth'
      security [bearer_auth: []]

      response(204, 'successful') do
        let(:user) { User.create!(email: 'test@example.com') }
        let(:Authorization) { "Bearer #{user.api_token}" }
        run_test!
      end
    end
  end

  path '/api/auth/refresh' do
    post('Refresh Token') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        },
        required: ['refresh_token']
      }

      response(200, 'successful') do
        # This assumes you have a refresh token implementation
        let(:user) { User.create!(email: 'test@example.com') }
        let(:params) { { refresh_token: 'fake_refresh_token' } }
        run_test!
      end
    end
  end

  path '/api/auth/me' do
    get('Get Current User') do
      tags 'Auth'
      produces 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:user) { User.create!(email: 'test@example.com', name: 'Test User') }
        let(:Authorization) { "Bearer #{user.api_token}" }
        run_test!
      end
    end
  end

  path '/api/auth/validate' do
    get('Validate Token') do
      tags 'Auth'
      security [bearer_auth: []]

      response(204, 'successful') do
        let(:user) { User.create!(email: 'test@example.com') }
        let(:Authorization) { "Bearer #{user.api_token}" }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { "Bearer invalid_token" }
        run_test!
      end
    end
  end
end
