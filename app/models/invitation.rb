class Invitation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :habit_plan

  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum :status, { pending: 0, accepted: 1, declined: 2 }
end
