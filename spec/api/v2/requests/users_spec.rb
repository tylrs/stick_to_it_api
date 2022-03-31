require "rails_helper"

RSpec.describe "Users v2", type: :request do
  describe "create user" do
    let(:headers) {{"Content-type": "application/json"}}

    context "when all required user info is submitted" do
      let(:user_details) {{ 
        name: "John Bob",
        username: "johnbob79",
        email: "johnbob7@example.com",
        password: "123456",
        password_confirmation: "123456"
      }}
      
      it "should respond with a success message" do
        post "/api/v2/users", headers: headers, params: JSON.generate(user_details)

        expect(response.status).to eq 201
      end

      it "should respond with the created user info" do
        post "/api/v2/users", headers: headers, params: JSON.generate(user_details)

        data = JSON.parse(response.body).symbolize_keys

        expect(data).to include(
          name: "John Bob",
          username: "johnbob79",
          email: "johnbob7@example.com",
          id: an_instance_of(Integer)
        )
      end
      
      it "should create a user in the database" do
        expect { post "/api/v2/users", 
                 headers: headers, 
                 params: JSON.generate(user_details) 
               }.to change {User.count}.by 1
      end      
    end

    it "should not be able to create a user without all required info" do
      user_details = {
        name: "",
        username: "johnbob79",
        email: "johnbob7@example.com",
        password: "123456",
        password_confirmation: ""
      }

      post "/api/v2/users", headers: headers, params: JSON.generate(user_details)
      created_user = User.last
      data = JSON.parse(response.body)
      expect(response.status).to eq 422
      expect(data["errors"][0]).to eq "Password confirmation doesn't match Password"
      expect(data["errors"][1]).to eq "Name can't be blank"
    end
  end
end
