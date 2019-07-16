# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: update_bath_lat_long'
  task update_bath_lat_long: :environment do
    puts "Running deploy task 'update_bath_lat_long'"

    # Put your task implementation HERE.
    SolarPvTuosArea.find_by(title: 'Bath').update!(latitude: 51.3751, longitude: -2.36172)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
