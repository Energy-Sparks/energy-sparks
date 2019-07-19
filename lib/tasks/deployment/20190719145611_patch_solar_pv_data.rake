namespace :after_party do
  desc 'Deployment task: patch_solar_pv_data'
  task patch_solar_pv_data: :environment do
    puts "Running deploy task 'patch_solar_pv_data'"

    area_ids = [5,8,10]

    area_ids.each do |area_id|

      reading_dates = ['2018-05-03', '2018-03-24', '2016-11-25']

      reading_dates.each do |date|
        reading_date = Date.parse(date)
        empty_record = DataFeeds::SolarPvTuosReading.find_by(area_id: area_id, reading_date: reading_date)
        substitute_readings = DataFeeds::SolarPvTuosReading.find_by(area_id: area_id, reading_date: reading_date -1.day).generation_mw_x48

        empty_record.update(generation_mw_x48: substitute_readings)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end