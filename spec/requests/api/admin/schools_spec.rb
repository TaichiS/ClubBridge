require 'swagger_helper'

describe 'Admin::Schools API', type: :request do
  let(:super_admin) { User.create!(email: "super@example.com", role: :super_admin) }
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let(:pending_school) { School.create!(name: "Pending School", status: :pending) }

  path '/api/admin/schools' do
    get('List all schools') do
      tags 'Admin::Schools'
      produces 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        before { school }
        run_test!
      end
    end
  end

  path '/api/admin/schools/{id}' do
    get('Show a school') do
      tags 'Admin::Schools'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { school.id }
        run_test!
      end
    end
  end

  path '/api/admin/schools/pending' do
    get('List pending schools') do
      tags 'Admin::Schools'
      produces 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        before { pending_school }
        run_test!
      end
    end
  end

  path '/api/admin/schools/{id}/approve' do
    post('Approve a school') do
      tags 'Admin::Schools'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string, description: 'ID of the school to approve'

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { pending_school.id }
        run_test!
      end
    end
  end

  path '/api/admin/schools/{id}/reject' do
    post('Reject a school') do
      tags 'Admin::Schools'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id', in: :path, type: :string, description: 'ID of the school to reject'

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{super_admin.api_token}" }
        let(:id) { pending_school.id }
        run_test!
      end
    end
  end
end
