require "rails_helper"

RSpec.describe HabitPlansFilterService do
  let(:habit_log) { create(:habit_log) }
  let(:user) { habit_log.habit_plan.user }
  let(:habit_plan) { habit_log.habit_plan }
  let(:habit_plan_next_week) { create(:habit_plan, {start_datetime: "2022/02/06", user: user}) }
  let(:habit) { habit_plan.habit }

  before do
    FactoryBot.create_list(:habit_log, 4, habit_plan_id: habit_plan.id) do |habit_log, i|
      date = Date.new(2022,2,3)
      date += i.days
      habit_log.scheduled_at = date
      habit_log.save
    end

    create(:habit_log, {scheduled_at: "2022/02/06", habit_plan: habit_plan_next_week})
  end

  describe ".get_week_and_partner_plans" do
    let(:habit_plans) { HabitPlansFilterService.get_week_and_partner_plans(user.id) }

    before do
      allow(Date).to receive(:today).and_return Date.new(2022,2,1)
    end

    describe "return value" do
      it "includes user's habit plans only for the current week" do
        expect(habit_plans.length).to eq 1
      end

      it "includes matching user" do
        expect(habit_plans[0].user).to eq user
      end
  
      it "includes habit for each habit plan" do
        expect(habit_plans[0].habit).to eq habit
      end
  
      it "includes only current week's logs" do
        expect(habit_plans[0].habit_logs.length).to eq 4
      end

      it "includes habit logs with scheduled_at dates for the current week" do
        expect(habit_plans[0].habit_logs).to contain_exactly(
          an_object_having_attributes(scheduled_at: Date.new(2022,2,2)),
          an_object_having_attributes(scheduled_at: Date.new(2022,2,3)),
          an_object_having_attributes(scheduled_at: Date.new(2022,2,4)),
          an_object_having_attributes(scheduled_at: Date.new(2022,2,5)),
        )
      end
    end

    context "when user has a partner on a habit" do
      let(:partner) { create(:user) }
      let(:partner_habit_plan) { create(:habit_plan, {user: partner, habit: habit}) }

      before do
        FactoryBot.create_list(:habit_log, 5, habit_plan_id: partner_habit_plan.id) do |habit_log, i|
          date = Date.new(2022,2,2)
          date += i.days
          habit_log.scheduled_at = date
          habit_log.save
        end
      end
 
      describe "return value" do
        it "includes partner's habit plan only for the current week" do
          expect(habit_plans.length).to eq 2
        end

        it "includes matching partner" do
          expect(habit_plans[1].user).to eq partner
        end
    
        it "includes habit for partner's habit plan" do
          expect(habit_plans[1].habit).to eq habit
        end
    
        it "includes only current week's logs" do
          expect(habit_plans[1].habit_logs.length).to eq 4
        end

        it "includes habit logs with scheduled_at dates for the current week" do
          expect(habit_plans[0].habit_logs).to contain_exactly(
            an_object_having_attributes(scheduled_at: Date.new(2022,2,2)),
            an_object_having_attributes(scheduled_at: Date.new(2022,2,3)),
            an_object_having_attributes(scheduled_at: Date.new(2022,2,4)),
            an_object_having_attributes(scheduled_at: Date.new(2022,2,5)),
          )
        end
      end
    end

    context "when a user has no habit plans for the current week" do
      let(:user) { create(:user) }

      it "returns no habit plans" do
        response = HabitPlansFilterService.get_week_and_partner_plans(user.id)
        
        expect(response.length).to eq 0
      end
    end
  end

  describe ".get_today_and_partner_plans" do
    let(:habit_plans) { HabitPlansFilterService.get_today_and_partner_plans(user.id) }
    let(:habit_plan_tomorrow) { create(:habit_plan, {start_datetime: "2022/02/03", user: user}) }

    before do
      allow(Date).to receive(:today).and_return Date.new(2022,2,2)
      
      create(:habit_log, {scheduled_at: Date.new(2022,2,3), habit_plan: habit_plan_tomorrow})
    end

    describe "return value" do
      it "includes user's habit plans only for today" do
        expect(habit_plans.length).to eq 1
      end

      it "includes matching user" do
        expect(habit_plans[0].user).to eq user
      end
  
      it "includes habit for each habit plan" do
        expect(habit_plans[0].habit).to eq habit
      end
  
      it "includes only one log per habit plan" do
        expect(habit_plans[0].habit_logs.length).to eq 1
      end
  
      it "includes the habit log for the current day" do
        expect(habit_plans[0].habit_logs[0].scheduled_at).to eq Date.new(2022,02,02)
      end
    end


    context "when user has a partner on a habit" do
      let(:partner) { create(:user) }
      let(:partner_habit_plan) { create(:habit_plan, {user: partner, habit: habit}) }

      before do
        FactoryBot.create_list(:habit_log, 4, habit_plan_id: partner_habit_plan.id) do |habit_log, i|
          date = Date.new(2022,2,2)
          date += i.days
          habit_log.scheduled_at = date
          habit_log.save
        end
      end

      describe "return value" do
        it "includes partner's habit plan only for today" do
          expect(habit_plans.length).to eq 2
        end
        it "includes matching partner" do
          expect(habit_plans[1].user).to eq partner
        end
    
        it "includes habit for partner's habit plan" do
          expect(habit_plans[1].habit).to eq habit
        end
    
        it "includes only one log per habit plan" do
          expect(habit_plans[1].habit_logs.length).to eq 1
        end
  
        it "includes the habit log for the current day" do
          expect(habit_plans[1].habit_logs[0].scheduled_at).to eq Date.new(2022,02,02)
        end
      end
    end

    context "when a user has no habit plans for the current day" do
      before do
        allow(Date).to receive(:today).and_return Date.new(2022,01,30)
      end

      it "returns no habit plans" do
        response = HabitPlansFilterService.get_today_and_partner_plans(user.id)
        
        expect(response.length).to eq 0
      end
    end
  end

  describe ".get_next_week_plans" do
    let!(:habit_plan_next_week_2) { create(:habit_plan, {start_datetime: "2022/02/12", end_datetime: "2022/02/19"}) }
    let!(:habit_plan_next_week_3) { create(:habit_plan, {start_datetime: "2022/02/04", end_datetime: "2022/02/06"}) }
    let!(:habit_plan_current_week) { create(:habit_plan, {start_datetime: "2022/02/02", end_datetime: "2022/02/05"}) }
    let(:next_week_plans) { HabitPlansFilterService.get_next_week_plans }

    before do
      allow(Date).to receive(:today).and_return Date.new(2022,2,1)
    end

    it "returns habit plans with a start date on or before the following Saturday and on or after next Sunday" do
      expect(next_week_plans).to contain_exactly(
        an_object_having_attributes(id: habit_plan.id),
        an_object_having_attributes(id: habit_plan_next_week.id),
        an_object_having_attributes(id: habit_plan_next_week_2.id),
        an_object_having_attributes(id: habit_plan_next_week_3.id)
      )
    end
  end

  describe ".determine_next_week_range" do
    let(:next_sunday) { Date.new(2022,2,6) }
    let(:following_saturday) { Date.new(2022,2,12) }
    let(:habit_plan) { create(:habit_plan, start_datetime: "2022/02/08", end_datetime: "2022/02/11") }
    let(:range) { HabitPlansFilterService.determine_next_week_range(habit_plan) }

    before do
      allow(Date).to receive(:today).and_return Date.new(2022,2,2)
    end

    it "returns range_beginning equal to habit plan start date" do
      expect(range[:range_beginning]).to eq Date.new(2022,2,8)
    end 

    it "returns range_end equal to habit plan end date" do
      expect(range[:range_end]).to eq Date.new(2022,2,11)
    end

    context "habit plan start date is before next Sunday" do
      let(:habit_plan) { create(:habit_plan, start_datetime: "2022/02/02", end_datetime: "2022/02/20") }
      let(:range) { HabitPlansFilterService.determine_next_week_range(habit_plan) }

      it "returns range_beginning as next sunday" do
        expect(range[:range_beginning]).to eq next_sunday
      end
    end

    context "habit plan end date is after the following Saturday" do
      let(:habit_plan) { create(:habit_plan, start_datetime: "2022/02/02", end_datetime: "2022/02/20") }
      let(:range) { HabitPlansFilterService.determine_next_week_range(habit_plan) }

      it "returns range_end as next_saturday" do
        expect(range[:range_end]).to eq following_saturday
      end
    end
  end
end