require "rails_helper"

RSpec.describe HabitPlanInviterMailer, type: :mailer do
  describe ".habit_plan_invite_email" do
    let(:email) {described_class.invite_email(user, habit_plan.id, "friend@example.com")}
    let(:habit_plan) { create(:habit_plan) }
    let(:user) { habit_plan.user }
    
    describe "headers" do
      it "has the correct sender" do
        expect(email.from).to eq "from@example.com"
      end
      
      it "has the correct recipient" do
        expect(email.to).to eq "friend@example.com"
      end

      it "has the correct subject" do
        expect(email.subject).to eq "#{user.name} wants you to join their habit"
      end
    end

    it "sends the email" do
      expect do
        described_class.invite_email(user, habit_plan.id, "friend@example.com")
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end