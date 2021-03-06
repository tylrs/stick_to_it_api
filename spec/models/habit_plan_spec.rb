require "rails_helper"

RSpec.describe HabitPlan, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:habit) }
    it { is_expected.to have_many(:habit_logs) }
    it { is_expected.to have_one(:invitation) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_datetime) }
    it { is_expected.to validate_presence_of(:end_datetime) }
  end
end
