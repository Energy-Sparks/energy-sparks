namespace :after_party do
  desc 'Deployment task: update_taxi_transport_type'
  task update_taxi_transport_type: :environment do
    puts "Running deploy task 'update_taxi_transport_type'"

    # Change taxi to be shareable
    TransportType.find_by(name: 'Taxi').update(kg_co2e_per_km: 0.20826, can_share: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
