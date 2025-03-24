namespace :after_party do
  desc 'Deployment task: set_school_local_distribution_zone'
  task set_school_local_distribution_zone: :environment do
    puts "Running deploy task 'set_school_local_distribution_zone'"

    School.active.each do |school|
      school.update!(local_distribution_zone_id: LocalDistributionZonePostcode.zone_id_for_school(school))
    end

    # Put your task implementation HERE.
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
