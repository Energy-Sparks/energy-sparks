namespace :after_party do
  desc 'Deployment task: add_solar_edge_data_feed_config'
  task add_solar_edge_data_feed_config: :environment do
    puts "Running deploy task 'add_solar_edge_data_feed_config'"

    # Put your task implementation HERE.
    energy_assets = {}
    energy_assets['description'] = "Solar Edge"
    energy_assets['identifier'] = 'solar-edge'
    energy_assets['date_format'] = "%d/%m/%Y"
    energy_assets['mpan_mprn_field'] = 'N/A'
    energy_assets['reading_date_field'] = 'N/A'
    energy_assets['reading_fields'] = 'N/A'
    energy_assets['process_type'] = :solar_edge_api
    energy_assets['source_type'] = :api

    AmrDataFeedConfig.create!(energy_assets)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end