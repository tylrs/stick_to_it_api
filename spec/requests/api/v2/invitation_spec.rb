require "rails_helper"

RSpec.describe "Invitations v2", type: :request do
  let(:habit_plan) { create(:habit_plan) }
  let(:user) { habit_plan.user }
  let(:token) { JsonWebTokenService.encode(user_id: user.id) }
  let(:headers) { { "Content-type": "application/json", "Authorization": "Bearer #{token}" } }
  let(:recipient_info) { { recipient_name: "Bob", recipient_email: "bob.friend@example.com" } }

  
  describe "#create" do
    it_behaves_like "a protected route" do
      let(:request_type) { :post }
      let(:path) do
        "/api/v2/users/#{user.id}/habit_plans/#{habit_plan.id}/invitations/create"
      end     
    end

    context "when the invitation record has been successfully created" do
      it "returns http success" do
        post "/api/v2/users/#{user.id}/habit_plans/#{habit_plan.id}/invitations/create",
             headers: headers,
             params: JSON.generate(recipient_info)
        expect(response).to be_ok
      end
            
      it "returns a success message" do
        post "/api/v2/users/#{user.id}/habit_plans/#{habit_plan.id}/invitations/create",
             headers: headers,
             params: JSON.generate(recipient_info)
        expect(parsed_response["message"]).to eq "Email Sent"
      end

      it "creates an invitation record" do
        expect do
          post "/api/v2/users/#{user.id}/habit_plans/#{habit_plan.id}/invitations/create",
               headers: headers,
               params: JSON.generate(recipient_info)
        end.to change { user.sent_invites.count }.by(1)
      end
    end

    context "when the invitation record creation fails" do
      let(:recipient_info) { { recipient_name: "Bob", recipient_email: "" } }
      before do
        post "/api/v2/users/#{user.id}/habit_plans/#{habit_plan.id}/invitations/create",
             headers: headers,
             params: JSON.generate(recipient_info)
      end

      it "returns an unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        expect(parsed_response["errors"]).to contain_exactly("Recipient email can't be blank", 
                                                             "Recipient email is invalid")
      end
    end

    context "when the user cannot be found" do
      before do
        post "/api/v2/users/500/habit_plans/#{habit_plan.id}/invitations/create",
             headers: headers,
             params: JSON.generate(recipient_info)
      end

      it "returns a not found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(parsed_response["errors"]).to eq "Couldn't find User with 'id'=500"
      end
    end

    context "when the habit plan cannot be found" do
      before do
        post "/api/v2/users/#{user.id}/habit_plans/500/invitations/create",
             headers: headers,
             params: JSON.generate(recipient_info)
      end

      it "returns a not found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(parsed_response["errors"]).to eq "Couldn't find HabitPlan with 'id'=500"
      end
    end
  end

  describe "#show_received" do
    let(:recipient) { create(:user) }

    it_behaves_like "a protected route" do
      let(:request_type) { :get }
      let(:path) do
        "/api/v2/users/#{recipient.id}/invitations/received"
      end     
    end

    context "when a user has pending invitations" do
      let(:token) { JsonWebTokenService.encode(user_id: recipient.id) } 
      let!(:pending_invitation) do 
        create(:invitation, { 
                 sender: user, 
                 recipient_email: recipient.email,
                 habit_plan: habit_plan 
               }) 
      end
      let!(:pending_invitation2) do 
        create(:invitation, { 
                 sender: user, 
                 recipient_email: recipient.email 
               }) 
      end

      let!(:accepted_invitation) do 
        create(:invitation, { 
                 sender: user, 
                 recipient_email: recipient.email,
                 status: "accepted" 
               }) 
      end
      let!(:declined_invitation) do 
        create(:invitation, { 
                 sender: user, 
                 recipient_email: recipient.email,
                 status: "declined" 
               }) 
      end

      before do
        get "/api/v2/users/#{recipient.id}/invitations/received", headers: headers
      end

      it "returns http success" do
        expect(response).to be_ok
      end

      it "returns pending invitations" do
        expect(parsed_response).to include(
          include("id" => pending_invitation.id),
          include("id" => pending_invitation2.id)
        )
      end

      describe "return value" do
        it "returns the correct keys" do
          invitation_keys = %w[id status habit_plan habit_plan_id sender recipient_email]
          
          expect(parsed_response[0].keys).to match_array(invitation_keys)
        end

        it "returns habit plan info keys" do
          habit_plan_info_keys = %w[start_datetime end_datetime habit]
            
          expect(parsed_response[0]["habit_plan"].keys).to match_array(habit_plan_info_keys)
        end
  
        it "returns habit info keys" do
          habit_info_keys = %w[name description] 
  
          expect(parsed_response[0]["habit_plan"]["habit"].keys).to match_array(habit_info_keys)
        end

        it "returns sender info keys" do
          sender_info_keys = %w[name username] 
  
          expect(parsed_response[0]["sender"].keys).to match_array(sender_info_keys)
        end
      end

      it "does not return already accepted invitations" do
        expect(parsed_response).not_to include(
          include("id" => accepted_invitation.id)
        )
      end

      it "does not return declined invitations" do
        expect(parsed_response).not_to include(
          include("id" => declined_invitation.id)
        )
      end
    end

    context "when a user has no pending invitations" do
      let(:recipient) { create(:user) }
      let(:token) { JsonWebTokenService.encode(user_id: recipient.id) } 

      before do
        get "/api/v2/users/#{recipient.id}/invitations/received", headers: headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(parsed_response["errors"]).to eq "No invitations found"
      end
    end
  end

  describe "#show_sent" do
    it_behaves_like "a protected route" do
      let(:request_type) { :get }
      let(:path) do
        "/api/v2/users/#{user.id}/invitations/sent"
      end     
    end

    context "when a user has sent invitations" do
      let!(:pending_invitation) do 
        create(:invitation, {
                 sender: user,
                 habit_plan: habit_plan 
               }) 
      end
      let!(:pending_invitation2) { create(:invitation, { sender: user }) }
      let!(:accepted_invitation) do 
        create(:invitation, { 
                 sender: user, 
                 status: "accepted" 
               }) 
      end
      let!(:declined_invitation) do 
        create(:invitation, { 
                 sender: user, 
                 status: "declined" 
               }) 
      end

      before do
        get "/api/v2/users/#{user.id}/invitations/sent", headers: headers
      end

      it "returns http success" do
        expect(response).to be_ok
      end

      it "returns all invitations" do
        expect(parsed_response).to include(
          include("id" => pending_invitation.id),
          include("id" => pending_invitation2.id),
          include("id" => accepted_invitation.id),
          include("id" => declined_invitation.id)
        )
      end

      describe "return value" do
        it "returns the correct keys" do
          invitation_keys = %w[id status habit_plan habit_plan_id sender recipient_email]
          
          expect(parsed_response[0].keys).to match_array(invitation_keys)
        end

        it "returns habit plan info keys" do
          habit_plan_info_keys = %w[start_datetime end_datetime habit]
            
          expect(parsed_response[0]["habit_plan"].keys).to match_array(habit_plan_info_keys)
        end
  
        it "returns habit info keys" do
          habit_info_keys = %w[name description] 
  
          expect(parsed_response[0]["habit_plan"]["habit"].keys).to match_array(habit_info_keys)
        end

        it "returns sender info keys" do
          sender_info_keys = %w[name username] 
  
          expect(parsed_response[0]["sender"].keys).to match_array(sender_info_keys)
        end
      end
    end

    context "when a user has no sent invitations" do
      before do
        get "/api/v2/users/#{user.id}/invitations/sent", headers: headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(parsed_response["errors"]).to eq "No sent invites found"
      end
    end
  end

  describe "#accept" do
    let(:recipient) { create(:user) }
    let(:token) { JsonWebTokenService.encode(user_id: recipient.id) }

    before do
      allow(Date).to receive(:today).and_return Date.new(2022, 2, 2)
    end

    it_behaves_like "a protected route" do
      let(:request_type) { :patch }
      let(:path) do
        "/api/v2/users/#{recipient.id}/invitations/1"
      end     
    end

    context "when a user has a pending invitation" do
      let!(:pending_invitation) do 
        create(:invitation, {
                 sender: user,
                 recipient_email: recipient.email,
                 habit_plan: habit_plan 
               }) 
      end

      it "returns http success" do
        patch "/api/v2/users/#{recipient.id}/invitations/#{pending_invitation.id}", 
              headers: headers

        expect(response).to be_ok
      end
      
      it "marks the invitation as accepted" do
        patch "/api/v2/users/#{recipient.id}/invitations/#{pending_invitation.id}", 
              headers: headers

        expect(parsed_response["status"]).to eq "accepted"
      end

      it "creates a habit plan" do
        expect do
          patch "/api/v2/users/#{recipient.id}/invitations/#{pending_invitation.id}", 
                headers: headers  
        end.to change { recipient.habit_plans.count }.by(1)
      end

      it "creates habit logs" do
        expect do
          patch "/api/v2/users/#{recipient.id}/invitations/#{pending_invitation.id}", 
                headers: headers  
        end.to change { recipient.habit_logs.count }.by(4)
      end
    end
    
    context "when the invitation is not pending" do
      let!(:accepted_invitation) do 
        create(:invitation, { 
                 sender: user, 
                 recipient_email: recipient.email,
                 status: "accepted" 
               }) 
      end

      it "returns http unprocessable entity" do
        patch "/api/v2/users/#{recipient.id}/invitations/#{accepted_invitation.id}", 
              headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        patch "/api/v2/users/#{recipient.id}/invitations/#{accepted_invitation.id}", 
              headers: headers  

        expect(parsed_response["errors"]).to eq "Invitation has already been #{accepted_invitation.status}"
      end

      it "does not create a habit plan" do
        expect do
          patch "/api/v2/users/#{recipient.id}/invitations/#{accepted_invitation.id}", 
                headers: headers  
        end.not_to(change { recipient.habit_plans.count })
      end

      it "does not create habit logs" do
        expect do
          patch "/api/v2/users/#{recipient.id}/invitations/#{accepted_invitation.id}", 
                headers: headers  
        end.not_to(change { recipient.habit_logs.count })
      end
    end

    context "when the invitation cannot be found" do
      it "returns http not found" do
        patch "/api/v2/users/#{recipient.id}/invitations/500", 
              headers: headers  

        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        patch "/api/v2/users/#{recipient.id}/invitations/500", 
              headers: headers  

        expect(parsed_response["errors"]).to eq "Couldn't find Invitation with 'id'=500"
      end

      it "does not create a habit plan" do
        expect do
          patch "/api/v2/users/#{recipient.id}/invitations/500", 
                headers: headers  
        end.not_to(change { recipient.habit_plans.count })
      end

      it "does not create habit logs" do
        expect do
          patch "/api/v2/users/#{recipient.id}/invitations/500", 
                headers: headers  
        end.not_to(change { recipient.habit_logs.count })
      end
    end
  end
end
