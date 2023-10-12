class SendReviewGroupTariffsReminderJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform
    SchoolGroup.all.find_each do |school_group|
      EnergyTariffsMailer.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver
    end
  end
end
