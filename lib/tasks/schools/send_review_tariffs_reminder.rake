# frozen_string_literal: true

namespace :schools do
  desc "Sends an email to school group admins to review the information we have about their school group's energy tariffs"
  task send_review_school_tariffs_reminder: :environment do


    School.active.find_each do |school|
      if school.energy_tariffs.enabled.current.any? { |tariff| tariff.end_date > 30.days.ago }
        
    User.school_admin


    begin
      SendReviewSchoolTariffsReminderJob.perform_later
    rescue StandardError => e
      error_message = "Exception: an email to school group admins to review the information we have about their school group's energy tariffs: #{e.class} #{e.message}"
      puts error_message
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :send_review_school_tariffs_reminder)
    end
  end
end
