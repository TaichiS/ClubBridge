require 'swagger_helper'

describe 'School Settings API', type: :request do
  let(:user) { User.create!(email: "test@example.com") }
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let!(:membership) { Membership.create!(user: user, school: school, role: :admin) }

  path '/api/schools/{school_id}/setting' do
    get('Show school settings') do
      tags 'School Settings'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        run_test!
      end
    end

    post('Create school settings') do
      tags 'School Settings'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :school_setting, in: :body, schema: {
        type: :object,
        properties: {
          school_setting: {
            type: :object,
            properties: {
              welcome_message: { type: :string }
            }
          }
        }
      }

      response(201, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:school_setting) { { school_setting: { welcome_message: "Created" } } }
        run_test!
      end
    end

    patch('Update school settings') do
      tags 'School Settings'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :school_setting, in: :body, schema: {
        type: :object,
        properties: {
          school_setting: {
            type: :object,
            properties: {
              welcome_message: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let!(:existing_setting) { school.create_school_setting! }
        let(:school_setting) { { school_setting: { welcome_message: "Updated" } } }
        run_test!
      end
    end
  end
end