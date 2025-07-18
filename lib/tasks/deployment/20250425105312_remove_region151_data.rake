namespace :after_party do
  desc 'Deployment task: remove_region151_data'
  task remove_region151_data: :environment do
    puts "Running deploy task 'remove_region151_data'"

    # No installed capacity for this id so all data is zeroes. Additional bug at our side
    # is creating NaN values. None of this should have been inserted
    area = SolarPvTuosArea.find_by_gsp_id(151)
    if area
      area.solar_pv_tuos_readings.destroy_all
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
