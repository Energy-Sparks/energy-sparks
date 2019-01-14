namespace :after_party do
  desc 'Deployment task: set_other_flag_on_activity_types'
  task set_other_flag_on_activity_types: :environment do
    puts "Running deploy task 'set_other_flag_on_activity_types'"

    ActivityType.transaction do
      ActivityType.all.each do |activity_type|
        if activity_type.name.match?(/^Other/)
          activity_type.update!(other: true)
        end
      end
    end

    AfterParty::TaskRecord.create version: '20190114141300'
  end
end
