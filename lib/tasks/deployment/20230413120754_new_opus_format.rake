namespace :after_party do
  desc 'Deployment task: new_opus_format'
  task new_opus_format: :environment do
    puts "Running deploy task 'new_opus_format'"

    identifier = "opus-hh"
    config = {}
    config["identifier"] = identifier
    config["description"] = "Opus HH Format"
    config["notes"] = "Used to process data exported from Excel sheets"
    config["date_format"] = "%d/%m/%Y"
    config['mpan_mprn_field'] = 'MPANCore'
    config['reading_date_field'] = 'Sett Date'
    config['reading_fields'] = ['Meter Read']
    config['header_example'] = "MPANCore,Sett Date,Sett Period,Type,Meter Read"
    config['row_per_reading'] = true
    config['positional_index'] = true
    config['number_of_header_rows'] = 2

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
