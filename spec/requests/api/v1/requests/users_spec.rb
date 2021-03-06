require "rails_helper"

RSpec.describe "Users v1", type: :request do
  describe "Create" do
    skip it "Should create a user with successful info" do
      user_details = {
        name: "John Bob",
        username: "johnbob79",
        email: "johnbob7@example.com",
        password: "123456",
        password_confirmation: "123456"
      }

      headers = { "Content-type": "application/json" }
      post "/api/v1/users", headers: headers, params: JSON.generate(user_details)
      created_user = User.last

      expect(response.status).to eq 201
      expect(JSON.parse(response.body)["name"]).to eq "John Bob"
      expect(created_user.name).to eq "John Bob"
    end

    skip it "Should not be able to create a user without all required info" do
      user_details = {
        name: "",
        username: "johnbob79",
        email: "johnbob7@example.com",
        password: "123456",
        password_confirmation: ""
      }

      headers = { "Content-type": "application/json" }
      post "/api/v1/users", headers: headers, params: JSON.generate(user_details)
      created_user = User.last
      data = JSON.parse(response.body)
      expect(response.status).to eq 422
      expect(data["errors"][0]).to eq "Password confirmation doesn't match Password"
      expect(data["errors"][1]).to eq "Name can't be blank"
    end

    skip it "Should be able to delete a user" do
      create(:user)
      user = User.first
      token = JsonWebTokenService.encode(user_id: user.id)
      headers = { "Content-type": "application/json", "Authorization": "Bearer #{token}" }

      delete "/api/v1/users/#{user.id}", headers: headers

      expect(response.status).to eq 204
      expect(User.all.length).to eq 0
    end
  end
end
