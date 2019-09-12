namespace :after_party do
  desc 'Deployment task: add_dark_sky_solar_for_highlands'
  task add_dark_sky_solar_for_highlands: :environment do
    puts "Running deploy task 'add_dark_sky_solar_for_highlands'"

    # Put your task implementation HERE.
    DarkSkyArea.where(title: "Highlands", latitude: 57.565289, longitude: -4.432566).first_or_create!
    SolarPvTuosArea.where(title: "Highlands", latitude: 57.565289, longitude: -4.432566).first_or_create!

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end