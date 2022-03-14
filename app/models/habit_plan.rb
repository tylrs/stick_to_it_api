class HabitPlan < ApplicationRecord
  belongs_to :user
  belongs_to :habit
  has_many :habit_logs, dependent: :destroy

  validates :start_datetime, presence: true
  validates :end_datetime, presence: true
end
