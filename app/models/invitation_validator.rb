class InvitationValidator < ActiveModel::Validator
  def validate(record)
    return unless Invitation.where(habit_plan_id: record.habit_plan_id, 
                                   status: "accepted")
                            .or(Invitation.where(habit_plan_id: record.habit_plan_id, 
                                                 status: "pending")
                                          .where.not(id: record.id)).exists?
    
    record.errors.add :habit_plan_limit, "Can only have one pending or accepted invitation per habit plan"
  end
end
