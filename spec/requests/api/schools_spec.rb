require 'swagger_helper'

describe 'Schools API', type: :request do
  let(:super_admin) { User.create!(email: "super@example.com", role: :super_admin) }
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

  path '/api/admin/schools/pending' do
    get('List pending schools') do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        before { School.create!(name: "Pending School", status: :pending) }
        run_test!
      end
    end
  end

  path '/api/admin/schools/{id}/approve' do
    post('Approve a school') do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string, description: 'ID of the school to approve'

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { School.create!(name: 'A New School').id }
        run_test!
      end
    end
  end
end