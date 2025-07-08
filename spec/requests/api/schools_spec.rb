require 'rails_helper'

RSpec.describe "Api::Schools", type: :request do
  let(:super_admin) { User.create!(email: "super@example.com", role: :super_admin) }
  let(:school_user) { User.create!(email: "school@example.com", role: :school_user) }

  describe "POST /api/schools/apply" do
    let(:valid_params) { { school: { name: "Test School" } } }

    # Assuming any logged-in user can apply for a school
    it "creates a new School" do
      expect {
        post "/api/schools/apply", params: valid_params, headers: auth_headers(school_user)
      }.to change(School, :count).by(1)
    end
  end

  # These actions should require a super_admin
  describe "Admin school actions" do
    let!(:pending_school) { School.create!(name: "Pending School", status: :pending) }

    describe "GET /api/admin/schools/pending" do
      it "returns pending schools for a super_admin" do
        get "/api/admin/schools/pending", headers: auth_headers(super_admin)
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.first["name"]).to eq(pending_school.name)
      end
    end

    describe "POST /api/admin/schools/:id/approve" do
      it "approves the school for a super_admin" do
        post "/api/admin/schools/#{pending_school.id}/approve", headers: auth_headers(super_admin)
        expect(pending_school.reload.status).to eq("approved")
      end
    end
  end
end
