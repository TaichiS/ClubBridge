require 'rails_helper'

RSpec.describe "Api::Students", type: :request do
  let!(:school1) { School.create!(name: "School One", status: :approved) }
  let!(:school2) { School.create!(name: "School Two", status: :approved) }

  let!(:student1_s1) { Student.create!(name: "Student 1 S1", school: school1, student_id: "S1001") }
  let!(:student2_s1) { Student.create!(name: "Student 2 S1", school: school1, student_id: "S1002") }
  let!(:student1_s2) { Student.create!(name: "Student 1 S2", school: school2, student_id: "S2001") }

  describe "GET /api/schools/:school_id/students" do
    it "returns only the students for the specified school" do
      get "/api/schools/#{school1.id}/students"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |s| s["id"] }).to match_array([student1_s1.id, student2_s1.id])
    end

    it "returns an empty array if the school has no students" do
      school3 = School.create!(name: "School Three", status: :approved)
      get "/api/schools/#{school3.id}/students"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(0)
    end
  end

  describe "POST /api/schools/:school_id/students" do
    let(:valid_attributes) { { name: "New Student", student_id: "S1003" } }

    it "creates a new student for the specified school" do
      expect {
        post "/api/schools/#{school1.id}/students", params: { student: valid_attributes }
      }.to change(Student, :count).by(1)

      new_student = Student.last
      expect(new_student.school).to eq(school1)
      expect(new_student.name).to eq("New Student")
    end

    it "returns a created status" do
      post "/api/schools/#{school1.id}/students", params: { student: valid_attributes }
      expect(response).to have_http_status(:created)
    end
  end

  describe "PATCH /api/schools/:school_id/students/:id" do
    let(:update_attributes) { { name: "Updated Student Name" } }

    it "updates the requested student" do
      patch "/api/schools/#{school1.id}/students/#{student1_s1.id}", params: { student: update_attributes }
      student1_s1.reload
      expect(student1_s1.name).to eq("Updated Student Name")
    end

    it "returns a success status" do
      patch "/api/schools/#{school1.id}/students/#{student1_s1.id}", params: { student: update_attributes }
      expect(response).to have_http_status(:success)
    end

    it "does not allow updating a student from another school" do
      patch "/api/schools/#{school1.id}/students/#{student1_s2.id}", params: { student: update_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/schools/:school_id/students/:id" do
    it "destroys the requested student" do
      expect {
        delete "/api/schools/#{school1.id}/students/#{student1_s1.id}"
      }.to change(Student, :count).by(-1)
    end

    it "returns a no content status" do
      delete "/api/schools/#{school1.id}/students/#{student1_s1.id}"
      expect(response).to have_http_status(:no_content)
    end

    it "does not allow deleting a student from another school" do
      expect {
        delete "/api/schools/#{school1.id}/students/#{student1_s2.id}"
      }.to_not change(Student, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
