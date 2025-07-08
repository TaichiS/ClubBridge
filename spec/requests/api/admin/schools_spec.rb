require 'rails_helper'

RSpec.describe "Api::Admin::Schools", type: :request do
  describe "GET /api/admin/schools/pending" do
    it "returns a success status" do
      get "/api/admin/schools/pending"
      expect(response).to have_http_status(:success)
    end

    it "returns all pending schools" do
      pending_school = School.create(name: "Pending School", status: :pending)
      approved_school = School.create(name: "Approved School", status: :approved)

      get "/api/admin/schools/pending"
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first["id"]).to eq(pending_school.id)
    end
  end

  describe "POST /api/admin/schools/:id/approve" do
    let(:school) { School.create(name: "Test School", status: :pending) }

    it "approves the school" do
      post "/api/admin/schools/#{school.id}/approve"
      school.reload
      expect(school.status).to eq("approved")
    end

    it "returns a success status" do
      post "/api/admin/schools/#{school.id}/approve"
      expect(response).to have_http_status(:success)
    end

    it "returns the approved school" do
      post "/api/admin/schools/#{school.id}/approve"
      json_response = JSON.parse(response.body)
      expect(json_response["status"]).to eq("approved")
    end
  end
end
