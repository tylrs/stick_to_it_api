require "rails_helper"

RSpec.describe Habit, type: :model do
  describe "Habit Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe "Relationships" do
    it { should have_many(:habit_plans) }
    it { should have_many(:users) }
    it { should belong_to(:creator) }
  end
end
