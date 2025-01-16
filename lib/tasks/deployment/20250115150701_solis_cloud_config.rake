namespace :after_party do
  desc 'Deployment task: solis_cloud_config'
  task solis_cloud_config: :environment do
    puts "Running deploy task 'solis_cloud_config'"

    config = {}
    config['description'] = 'SolisCloud'
    config['identifier'] = 'solis_cloud'
    config['date_format'] = 'n/a'
    config['mpan_mprn_field'] = 'n/a'
    config['reading_date_field'] = 'n/a'
    config['reading_fields'] = []
    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
