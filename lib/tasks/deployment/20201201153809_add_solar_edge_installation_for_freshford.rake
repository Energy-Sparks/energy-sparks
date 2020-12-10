namespace :after_party do
  desc 'Deployment task: add_solar_edge_installation_for_freshford'
  task add_solar_edge_installation_for_freshford: :environment do
    puts "Running deploy task 'add_solar_edge_installation_for_freshford'"

    # Put your task implementation HERE.
    solar_edge_params = {}
    solar_edge_params['school_id'] = School.find_by_name('Freshford Church School').id
    solar_edge_params['amr_data_feed_config_id'] = AmrDataFeedConfig.find_by_identifier('solar-edge').id
    solar_edge_params['site_id'] = '1508552'
    solar_edge_params['mpan'] = '2000051383834'
    solar_edge_params['api_key'] = '1234567890'

    SolarEdgeInstallation.create!(solar_edge_params)


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end