namespace :after_party do
  desc 'Deployment task: bulk_load_carbon_intensity'
  task bulk_load_carbon_intensity: :environment do
    puts "Running deploy task 'bulk_load_carbon_intensity'"

    rake_process_carbon_feed(Date.parse('2017-09-19'), Date.yesterday)

    AfterParty::TaskRecord.create version: '20190429083141'
  end
end
