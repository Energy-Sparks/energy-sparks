namespace :after_party do
  desc 'Deployment task: add_corona_weekly_format'
  task add_corona_weekly_format: :environment do
    puts "Running deploy task 'add_corona_weekly_format'"

    identifier = "corona-weekly"
    config = {}
    config["identifier"] = identifier
    config["description"] = "Corona Weekly"
    config["notes"] = "For processing data sent on a weekly basis to the data inbox"
    config['header_example'] = "Date,Loaded,MPAN,Total,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50"
    config['number_of_header_rows'] = 1
    config["date_format"] = "%d/%m/%Y"
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'Date'
    config['reading_fields'] = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48".split(",")

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: identifier)
    if amr_data_feed_config
      amr_data_feed_config.update!(config)
    else
      AmrDataFeedConfig.create!(config)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
