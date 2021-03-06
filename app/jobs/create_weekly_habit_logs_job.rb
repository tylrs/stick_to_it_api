class CreateWeeklyHabitLogsJob < ApplicationJob
  sidekiq_options queue: :default, retry: 3

  def perform
    habit_plans = HabitPlansFilterService.next_week_plans
    habit_plans.each do |habit_plan|
      HabitLogsCreationService.create_logs(habit_plan, 
                                           HabitLogsCreationService::WEEK_TYPES[:next_week])  
    end
  end
end
