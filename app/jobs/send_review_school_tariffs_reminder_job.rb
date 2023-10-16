class SendReviewSchoolTariffsReminderJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform
    School.all.find_each do |school|
      EnergyTariffsMailer.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver
    end
  end
end
