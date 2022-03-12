require "rails_helper"

RSpec.describe "HabitPlans", type: :request do
  describe "Get HabitPlans" do
    before(:all) do
      @habit_log = create(:habit_log)
      @user = User.last
      @habit_plan = HabitPlan.last
      token = JsonWebTokenService.encode(user_id: @user.id)
      @headers = {"Content-type": "application/json", "Authorization": "Bearer #{token}"}
      FactoryBot.create_list(:habit_log, 3, habit_plan_id: @habit_plan.id) do |habit_log, i|
        date = Date.new(2022,2,3)
        date += i.days
        habit_log.scheduled_at = date
        habit_log.save
      end
    end

    it "Should return HabitPlans, habit info, and HabitLogs for this week and not any other week" do
      allow(Date).to receive(:today).and_return Date.new(2022,2,1)

      get "/api/v2/users/#{@user.id}/habit_plans/week", headers: @headers

      habits = JSON.parse(response.body)
      habit1 = habits[0]

      expect(response.status).to eq 201
      expect(habits.length).to eq 1
      expect(habit1["user_id"]).to eq @user.id
      expect(habit1["habit_id"]).to eq @habit_plan.habit_id
      expect(habit1["habit_plan_id"]).to eq @habit_plan.id
      expect(habit1["name"]).to eq "Running"
      expect(habit1["description"]).to eq "Run every day"
      expect(habit1["start_datetime"]).to eq Date.new("2022/02/02")
      expect(habit1["end_datetime"]).to eq Date.new("2022/02/10")
      expect(habit1["habit_logs"].length).to eq 4   
    end

    it "Should not return HabitPlans for this week if there are none scheduled" do
      allow(Date).to receive(:today).and_return Date.new(2022,2,8)
      
    end

    it "Should return HabitPlans for today" do
      allow(Date).to receive(:today).and_return Date.new(2022,2,2)
      
    end
  end
end
