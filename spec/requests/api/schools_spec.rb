require 'swagger_helper'

describe 'Schools API', type: :request do
  let(:school_user) { User.create!(email: "school@example.com", role: :school_user) }

  path '/api/schools/apply' do
    post('Apply for a new school') do
      tags 'Schools'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :school, in: :body, schema: {
        type: :object,
        properties: {
          school: {
            type: :object,
            properties: {
              name: { type: :string, description: 'The name of the new school', example: 'My Awesome School' }
            },
            required: ['name']
          }
        }
      }

      response(201, 'successful') do
        let(:Authorization) { "Bearer #{school_user.api_token}" }
        let(:school) { { school: { name: 'Test School' } } }
        run_test!
      end
    end
  end
end
