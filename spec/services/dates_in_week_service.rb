require "rails_helper"

RSpec.describe DatesInWeekService do
  describe ".get_week_start" do
    before do
      allow(Date).to receive(:today).and_return(Date.new(2022, 2, 2))
    end

    context "when week_type is current_week" do
      it "returns the most recent Sunday of the current week" do
        week_start = described_class.get_week_start(HabitLogsCreationService::WEEK_TYPES[:current])

        expect(week_start).to eq Date.new(2022, 1, 30)
      end
    end

    context "when week_type is next_week" do
      it "returns the most recent Sunday of next week" do
        week_start = described_class.get_week_start(HabitLogsCreationService::WEEK_TYPES[:next])

        expect(week_start).to eq Date.new(2022, 2, 6)
      end
    end
  end

  describe ".get_week_end" do
    before do
      allow(Date).to receive(:today).and_return(Date.new(2022, 2, 2))
    end
    
    context "when week_type is current_week" do
      it "returns the next Saturday of the current week" do
        week_end = described_class.get_week_end(HabitLogsCreationService::WEEK_TYPES[:current])

        expect(week_end).to eq Date.new(2022, 2, 5)
      end
    end

    context "when week_type is next_week" do
      it "returns the next Saturday of next week" do
        week_end = described_class.get_week_end(HabitLogsCreationService::WEEK_TYPES[:next])

        expect(week_end).to eq Date.new(2022, 2, 12)
      end
    end
  end
end
