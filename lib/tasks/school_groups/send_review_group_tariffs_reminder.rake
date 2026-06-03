namespace :school_groups do
  desc "Sends an email to school group admins to review the information we have about their school group's energy tariffs"
  task send_review_group_tariffs_reminder: :environment do
    return unless ENV['SEND_AUTOMATED_EMAILS'] == 'true'
    # Note: see `.ebextensions/cronjob.config` for dates and times this task is scheduled to run
    begin
      SendReviewGroupTariffsReminderJob.perform_later
    rescue => e
      error_message = "Exception: sending an email to school group admins to review the information we have about their school group's energy tariffs: #{e.class} #{e.message}"
      puts error_message
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :send_review_group_tariffs_reminder)
    end
  end
end
