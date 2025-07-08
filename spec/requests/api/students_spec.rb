require 'swagger_helper'

describe 'Students API', type: :request do
  let(:user) { User.create!(email: "test@example.com") }
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let!(:membership) { Membership.create!(user: user, school: school, role: :admin) }

  path '/api/schools/{school_id}/students' do
    get('List students') do
      tags 'Students'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        before { Student.create!(name: "Test Student", school: school, student_id: "S001") }
        run_test!
      end
    end

    post('Create a student') do
      tags 'Students'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :student, in: :body, schema: {
        type: :object,
        properties: {
          student: {
            type: :object,
            properties: {
              name: { type: :string },
              student_id: { type: :string }
            },
            required: ['name', 'student_id']
          }
        }
      }

      response(201, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:student) { { student: { name: 'New Student', student_id: 'S002' } } }
        run_test!
      end
    end
  end

  path '/api/schools/{school_id}/students/{id}' do
    parameter name: 'school_id', in: :path, type: :string
    parameter name: 'id', in: :path, type: :string

    patch('Update a student') do
      tags 'Students'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :student, in: :body, schema: {
        type: :object,
        properties: {
          student: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:id) { Student.create!(name: "Old Name", school: school, student_id: "S003").id }
        let(:student) { { student: { name: 'New Name' } } }
        run_test!
      end
    end

    delete('Delete a student') do
      tags 'Students'
      security [bearer_auth: []]

      response(204, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:id) { Student.create!(name: "To be deleted", school: school, student_id: "S004").id }
        run_test!
      end
    end
  end

  path '/api/schools/{school_id}/students/import' do
    post('Import students from Excel') do
      tags 'Students'
      consumes 'multipart/form-data'
      security [bearer_auth: []]
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :file, in: :formData, type: :file, required: true

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:school_id) { school.id }
        let(:file) { fixture_file_upload('test/fixtures/files/students.xlsx') }
        run_test!
      end
    end
  end
end