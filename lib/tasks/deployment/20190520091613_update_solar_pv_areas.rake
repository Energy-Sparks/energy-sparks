# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: update_solar_pv_areas'
  task update_solar_pv_areas: :environment do
    puts "Running deploy task 'update_solar_pv_areas'"

    # Put your task implementation HERE.
    SolarPvTuosArea.find_by(title: 'Bath').update(latitude: 51.39, longitude: -2.37)
    SolarPvTuosArea.find_by(title: 'Frome').update(latitude: 51.2308, longitude: -2.3201)
    SolarPvTuosArea.find_by(title: 'Sheffield').update(latitude: 53.3811, longitude: -1.4701)
    SolarPvTuosArea.find_by(title: 'Oxfordshire').update(latitude: 51.67, longitude: -1.285)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
