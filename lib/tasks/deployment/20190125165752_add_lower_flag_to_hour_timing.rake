namespace :after_party do
  desc 'Deployment task: add_lower_flag_to_hour_timing'
  task add_lower_flag_to_hour_timing: :environment do
    puts "Running deploy task 'add_lower_flag_to_hour_timing'"
    ActivityTiming.where(name: 'under 1 hour').update_all(include_lower: true)
    AfterParty::TaskRecord.create version: '20190125165752'
  end
end
