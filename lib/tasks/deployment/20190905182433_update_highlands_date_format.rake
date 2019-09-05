namespace :after_party do
  desc 'Deployment task: update_highlands_date_format'
  task update_highlands_date_format: :environment do
    puts "Running deploy task 'update_highlands_date_format'"

    # Put your task implementation HERE.

    AmrDataFeedConfig.find_by(description: 'Highlands').update(date_format: '%Y-%m-%d')

    highland_schools = School.where(calendar_area_id: 25)

    # Update meter ids
    if highland_schools.any?
      highland_schools.each do |school|
        next unless school.meters.any?
        school.meters.each do |meter|
          MeterManagement.new(meter).process_creation!
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end