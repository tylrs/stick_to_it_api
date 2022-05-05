require "rails_helper"

RSpec.describe HabitPlanInviterMailer, type: :mailer do
  describe ".habit_plan_invite_email" do
    let(:recipient_info) {{name: "Bob", email: "bob.friend@example.com"}}
    let(:email) {described_class.plan_invite_email(user, habit_plan, recipient_info)}
    let(:habit_plan) { create(:habit_plan) }
    let(:user) { habit_plan.user }
    
    describe "headers" do
      it "has the correct sender" do
        expect(email.from).to eq ["from@example.com"]
      end
      
      it "has the correct recipient" do
        expect(email.to).to eq ["#{recipient_info[:email]}"]
      end

      it "has the correct reply-to" do
        expect(email.reply_to).to eq ["#{user.email}"]
      end

      it "has the correct subject" do
        expect(email.subject).to eq "#{user.name} wants you to join their habit: #{habit_plan.habit.name}"
      end
    end

    describe "body" do
      it "returns the correct plain text" do
        expect(email.text_part.body.to_s).to include("Hello #{recipient_info[:name]}")
        expect(email.text_part.body.to_s).to include("#{user.name} would like you to join them on their new habit: #{habit_plan.habit.name}")
        expect(email.text_part.body.to_s).to include("They are planning on working on the habit from #{habit_plan.start_datetime} to #{habit_plan.end_datetime}")
        expect(email.text_part.body.to_s).to include("If you would like to accept, please click here:")
      end
      
      it "returns the correct html" do
        expect(email.html_part.body.to_s).to include("Hello #{recipient_info[:name]}")
        expect(email.html_part.body.to_s).to include("#{user.name} would like you to join them on their new habit: #{habit_plan.habit.name}")
        expect(email.html_part.body.to_s).to include("They are planning on working on the habit from #{habit_plan.start_datetime} to #{habit_plan.end_datetime}")
        expect(email.html_part.body.to_s).to include("If you would like to accept, please click here:")
      end
    end

    it "sends the email" do
      expect do
        described_class.plan_invite_email(user, habit_plan, recipient_info).deliver_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
