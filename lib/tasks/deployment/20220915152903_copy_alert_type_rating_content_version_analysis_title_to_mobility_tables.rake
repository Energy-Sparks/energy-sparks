namespace :after_party do
  desc 'Deployment task: copy_alert_type_rating_content_version_analysis_title_to_mobility_tables'
  task copy_alert_type_rating_content_version_analysis_title_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_alert_type_rating_content_version_analysis_title_to_mobility_tables'"

    AlertTypeRatingContentVersion.transaction do
      AlertTypeRatingContentVersion.all.each do |alert_type_rating_content_version|
        alert_type_rating_content_version.update(analysis_title: alert_type_rating_content_version.read_attribute(:analysis_title))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
