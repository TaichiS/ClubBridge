require 'swagger_helper'

describe 'Club Selections API', type: :request do
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let(:student) { Student.create!(school: school, name: "Test Student", student_id: "S001", id_card_number: "A123456789") }
  let!(:club1) { Club.create!(school: school, name: "Club 1", club_number: 1, category: "Test", teacher_name: "T1", description: "D1", max_members: 10, location: "L1") }
  let!(:club2) { Club.create!(school: school, name: "Club 2", club_number: 2, category: "Test", teacher_name: "T2", description: "D2", max_members: 10, location: "L2") }
  let!(:club3) { Club.create!(school: school, name: "Club 3", club_number: 3, category: "Test", teacher_name: "T3", description: "D3", max_members: 10, location: "L3") }

  # Note: Student authentication is not implemented yet.
  # For now, we are not testing authorization, just the action itself.

  path '/api/schools/{school_id}/club_selections' do
    post('Create club selections for a student') do
      tags 'Club Selections'
      consumes 'application/json'
      produces 'application/json'
      security []
      parameter name: 'school_id', in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          club_selection: {
            type: :object,
            properties: {
              student_id: { type: :integer },
              club_ids: { type: :array, items: { type: :integer } }
            },
            required: ['student_id', 'club_ids']
          }
        },
        required: ['club_selection']
      }

      response(201, 'successful') do
        let(:school_id) { school.id }
        let(:params) do
          {
            club_selection: {
              student_id: student.id,
              club_ids: [club2.id, club1.id, club3.id]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(3)
          expect(data.first['club_id']).to eq(club2.id)
          expect(data.first['preference']).to eq(1)
          expect(data.second['preference']).to eq(2)
          expect(student.club_selections.count).to eq(3)
        end
      end

      response(404, 'student not found') do
        let(:school_id) { school.id }
        let(:params) do
          {
            club_selection: {
              student_id: 9999,
              club_ids: [club1.id]
            }
          }
        end
        run_test!
      end

      response(404, 'club not found') do
        let(:school_id) { school.id }
        let(:params) do
          {
            club_selection: {
              student_id: student.id,
              club_ids: [9999]
            }
          }
        end
        run_test!
      end

      response(400, 'invalid parameters') do
        let(:school_id) { school.id }
        let(:params) do
          {
            club_selection: {
              student_id: student.id,
              club_ids: "not-an-array"
            }
          }
        end
        run_test!
      end
    end
  end
end
