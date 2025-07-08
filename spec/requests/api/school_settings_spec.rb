require 'rails_helper'

RSpec.describe "Api::SchoolSettings", type: :request do
  let(:user) { User.create!(email: "test@example.com") }
  let(:school) { School.create!(name: "Test School", status: :approved) }
  let!(:membership) { Membership.create!(user: user, school: school, role: :admin) }

  describe "GET /api/schools/:school_id/setting" do
    context "when setting does not exist" do
      it "returns a new setting object" do
        get "/api/schools/#{school.id}/setting", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to be_nil
        expect(json_response["welcome_message"]).to be_nil
      end
    end

    context "when setting exists" do
      let!(:setting) { school.create_school_setting!(welcome_message: "Hello!") }

      it "returns the existing setting" do
        get "/api/schools/#{school.id}/setting", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(setting.id)
        expect(json_response["welcome_message"]).to eq("Hello!")
      end
    end
  end

  describe "POST /api/schools/:school_id/setting" do
    let(:valid_attributes) { { welcome_message: "Welcome to our school!" } }

    it "creates a new setting" do
      expect {
        post "/api/schools/#{school.id}/setting", params: { school_setting: valid_attributes }, headers: auth_headers(user)
      }.to change(SchoolSetting, :count).by(1)
      expect(school.reload.school_setting.welcome_message).to eq("Welcome to our school!")
    end
  end

  describe "PATCH /api/schools/:school_id/setting" do
    let(:update_attributes) { { welcome_message: "Enrollment has started!" } }

    context "when setting does not exist" do
      it "creates a new setting" do
        patch "/api/schools/#{school.id}/setting", params: { school_setting: update_attributes }, headers: auth_headers(user)
        expect(school.reload.school_setting).to_not be_nil
        expect(school.school_setting.welcome_message).to eq("Enrollment has started!")
      end
    end

    context "when setting exists" do
      let!(:setting) { school.create_school_setting!(welcome_message: "Hello!") }

      it "updates the existing setting" do
        patch "/api/schools/#{school.id}/setting", params: { school_setting: update_attributes }, headers: auth_headers(user)
        setting.reload
        expect(setting.welcome_message).to eq("Enrollment has started!")
      end
    end
  end
end
