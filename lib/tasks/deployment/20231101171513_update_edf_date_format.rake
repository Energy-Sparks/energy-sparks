namespace :after_party do
  desc 'Deployment task: update_edf_date_format'
  task update_edf_date_format: :environment do
    puts "Running deploy task 'update_edf_date_format'"

    #The EDF format has incorrect date format configured. This isn't an issue
    #as the date/time is being parsed via some custom code, but the config
    #should match
    config = AmrDataFeedConfig.find_by_identifier('edf')
    if config
      config.update!(date_format: '%d %b %Y %H:%M:%S')
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
