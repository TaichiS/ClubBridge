require 'rails_helper'

RSpec.describe "Api::Schools", type: :request do
  describe "POST /api/schools/apply" do
    context "with valid parameters" do
      let(:valid_params) { { school: { name: "Test School" } } }

      it "creates a new School" do
        expect {
          post "/api/schools/apply", params: valid_params
        }.to change(School, :count).by(1)
      end

      it "returns a created status" do
        post "/api/schools/apply", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "returns the created school" do
        post "/api/schools/apply", params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("Test School")
        expect(json_response["status"]).to eq("pending")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { school: { name: "" } } }

      it "does not create a new School" do
        expect {
          post "/api/schools/apply", params: invalid_params
        }.to_not change(School, :count)
      end

      it "returns an unprocessable entity status" do
        post "/api/schools/apply", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
