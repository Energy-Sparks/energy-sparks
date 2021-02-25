namespace :after_party do
  desc 'Deployment task: Add system default feed config for N3RGY'
  task add_n3rgy_feed_config: :environment do
    puts "Running deploy task 'add_n3rgy_feed_config'"

    config = {}
    config['description'] = "N3RGY API"
    config['identifier'] = 'n3rgy-api'
    config['date_format'] = "%Y%m%d"
    config['mpan_mprn_field'] = 'N/A'
    config['reading_date_field'] = 'N/A'
    config['reading_fields'] = 'N/A'
    config['process_type'] = :n3rgy_api
    config['source_type'] = :api

    fc = AmrDataFeedConfig.find_by_identifier('n3rgy-api')
    if fc.nil?
      AmrDataFeedConfig.create!(config)
    else
      fc.update!(config)
    end


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
