namespace :after_party do
  desc 'Deployment task: update_bath_lat_lng'
  task update_bath_lat_lng: :environment do
    puts "Running deploy task 'update_bath_lat_lng'"

    DarkSkyArea.where(title: 'Bath').update_all(latitude: 51.3751, longitude: -2.36172)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
