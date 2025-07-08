require 'rails_helper'

RSpec.describe "Api::Students", type: :request do
  let(:user) { User.create!(email: "test@example.com") }
  let(:school1) { School.create!(name: "School One", status: :approved) }
  let(:school2) { School.create!(name: "School Two", status: :approved) }
  let!(:membership1) { Membership.create!(user: user, school: school1, role: :admin) }
  let!(:membership2) { Membership.create!(user: user, school: school2, role: :admin) }

  let!(:student1_s1) { Student.create!(name: "Student 1 S1", school: school1, student_id: "S1001") }
  let!(:student2_s1) { Student.create!(name: "Student 2 S1", school: school1, student_id: "S1002") }
  let!(:student1_s2) { Student.create!(name: "Student 1 S2", school: school2, student_id: "S2001") }

  describe "GET /api/schools/:school_id/students" do
    it "returns only the students for the specified school" do
      get "/api/schools/#{school1.id}/students", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |s| s["id"] }).to match_array([student1_s1.id, student2_s1.id])
    end

    it "returns forbidden if user does not have access to the school" do
      other_user = User.create!(email: "other@example.com")
      get "/api/schools/#{school1.id}/students", headers: auth_headers(other_user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/schools/:school_id/students" do
    let(:valid_attributes) { { name: "New Student", student_id: "S1003" } }

    it "creates a new student for the specified school" do
      expect {
        post "/api/schools/#{school1.id}/students", params: { student: valid_attributes }, headers: auth_headers(user)
      }.to change(Student, :count).by(1)

      new_student = Student.last
      expect(new_student.school).to eq(school1)
      expect(new_student.name).to eq("New Student")
    end
  end

  describe "PATCH /api/schools/:school_id/students/:id" do
    let(:update_attributes) { { name: "Updated Student Name" } }

    it "updates the requested student" do
      patch "/api/schools/#{school1.id}/students/#{student1_s1.id}", params: { student: update_attributes }, headers: auth_headers(user)
      student1_s1.reload
      expect(student1_s1.name).to eq("Updated Student Name")
    end
  end

  describe "DELETE /api/schools/:school_id/students/:id" do
    it "destroys the requested student" do
      expect {
        delete "/api/schools/#{school1.id}/students/#{student1_s1.id}", headers: auth_headers(user)
      }.to change(Student, :count).by(-1)
    end
  end

  describe "POST /api/schools/:school_id/students/import" do
    let(:school_for_import) { School.create!(name: "Import Test School", status: :approved) }
    let!(:import_membership) { Membership.create!(user: user, school: school_for_import, role: :admin) }
    let(:file) { fixture_file_upload('test/fixtures/files/students.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

    it "imports students from the Excel file" do
      expect {
        post "/api/schools/#{school_for_import.id}/students/import", params: { file: file }, headers: auth_headers(user)
      }.to change(school_for_import.students, :count).by(2)
    end
  end
end
