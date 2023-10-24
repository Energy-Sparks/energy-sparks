namespace :after_party do
  desc 'Deployment task: add_translated_alert_type_rating_content_version_email_and_sms'
  task add_translated_alert_type_rating_content_version_email_and_sms: :environment do
    puts "Running deploy task 'add_translated_alert_type_rating_content_version_email_and_sms'"

    AlertTypeRatingContentVersion.all.each do |alert_type_rating_content_version|
      alert_type_rating_content_version.update!(
        email_title_en: alert_type_rating_content_version[:email_title],
        sms_content_en: alert_type_rating_content_version[:sms_content]
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end