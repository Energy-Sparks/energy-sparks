namespace :schools do
  desc "Sends an email to school group admins to review the information we have about their school group's energy tariffs"
  task send_review_school_tariffs_reminder: :environment do
    return unless SendReviewSchoolTariffsReminderJob.new.send?

    begin
      SendReviewSchoolTariffsReminderJob.perform_later
    rescue => e
      error_message = "Exception: an email to school group admins to review the information we have about their school group's energy tariffs: #{e.class} #{e.message}"
      puts error_message
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :send_review_school_tariffs_reminder)
    end
  end
end
