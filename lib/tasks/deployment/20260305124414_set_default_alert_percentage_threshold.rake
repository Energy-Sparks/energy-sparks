namespace :after_party do
  desc 'Deployment task: set_default_alert_percentage_threshold'
  task set_default_alert_percentage_threshold: :environment do
    puts "Running deploy task 'set_default_alert_percentage_threshold'"

    DataSource.find_each do |data_source|
      data_source.update(alert_percentage_threshold: 25) unless data_source.alert_percentage_threshold
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
