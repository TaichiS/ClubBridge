require 'rails_helper'

RSpec.describe "Api::Clubs", type: :request do
  let!(:school1) { School.create!(name: "School One", status: :approved) }
  let!(:school2) { School.create!(name: "School Two", status: :approved) }

  let!(:club1_s1) { Club.create!(name: "Basketball Club", school: school1, club_number: "C101", category: "Sports", teacher_name: "Mr. Smith", description: "Play basketball", max_members: 20, location: "Gym") }
  let!(:club2_s1) { Club.create!(name: "Art Club", school: school1, club_number: "C102", category: "Arts", teacher_name: "Ms. Jones", description: "Draw and paint", max_members: 15, location: "Art Room") }
  let!(:club1_s2) { Club.create!(name: "Chess Club", school: school2, club_number: "C201", category: "Games", teacher_name: "Mr. Brown", description: "Play chess", max_members: 10, location: "Library") }

  describe "GET /api/schools/:school_id/clubs" do
    it "returns only the clubs for the specified school" do
      get "/api/schools/#{school1.id}/clubs"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |c| c["id"] }).to match_array([club1_s1.id, club2_s1.id])
    end
  end

  describe "POST /api/schools/:school_id/clubs" do
    let(:valid_attributes) { { name: "New Club", club_number: "C103", category: "Music", teacher_name: "Mr. Davis", description: "Play music", max_members: 25, location: "Music Room" } }

    it "creates a new club for the specified school" do
      expect {
        post "/api/schools/#{school1.id}/clubs", params: { club: valid_attributes }
      }.to change(school1.clubs, :count).by(1)
    end
  end

  describe "PATCH /api/schools/:school_id/clubs/:id" do
    let(:update_attributes) { { name: "Updated Club Name" } }

    it "updates the requested club" do
      patch "/api/schools/#{school1.id}/clubs/#{club1_s1.id}", params: { club: update_attributes }
      club1_s1.reload
      expect(club1_s1.name).to eq("Updated Club Name")
    end

    it "does not allow updating a club from another school" do
      patch "/api/schools/#{school1.id}/clubs/#{club1_s2.id}", params: { club: update_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/schools/:school_id/clubs/:id" do
    it "destroys the requested club" do
      expect {
        delete "/api/schools/#{school1.id}/clubs/#{club1_s1.id}"
      }.to change(school1.clubs, :count).by(-1)
    end

    it "does not allow deleting a club from another school" do
      delete "/api/schools/#{school1.id}/clubs/#{club1_s2.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
