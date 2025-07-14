require 'swagger_helper'

describe 'Admin::Users API', type: :request do
  let(:super_admin) { User.create!(email: "super@example.com", role: :super_admin) }
  let(:user) { User.create!(email: "test@example.com", name: "Test User") }
  let(:school) { School.create!(name: "Test School", status: :approved) }

  path '/api/admin/users' do
    get('List all users') do
      tags 'Admin::Users'
      produces 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        before { user }
        run_test!
      end
    end
  end

  path '/api/admin/users/{id}' do
    get('Show a user') do
      tags 'Admin::Users'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { user.id }
        run_test!
      end
    end

    patch('Update a user') do
      tags 'Admin::Users'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              role: { type: :string, enum: ['school_user', 'super_admin'] }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { user.id }
        let(:user_params) { { user: { name: "Updated Name" } } }
        run_test!
      end
    end
  end

  path '/api/admin/users/{id}/add_school' do
    post('Add a school to a user') do
      tags 'Admin::Users'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          school_id: { type: :integer },
          role: { type: :string, enum: ['admin', 'teacher'] }
        },
        required: ['school_id', 'role']
      }

      response(201, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { user.id }
        let(:params) { { school_id: school.id, role: 'admin' } }
        run_test!
      end
    end
  end

  path '/api/admin/users/{id}/remove_school' do
    delete('Remove a school from a user') do
      tags 'Admin::Users'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          school_id: { type: :integer }
        },
        required: ['school_id']
      }

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { user.id }
        let(:params) { { school_id: school.id } }
        before { user.memberships.create!(school: school, role: :admin) }
        run_test!
      end
    end
  end
end