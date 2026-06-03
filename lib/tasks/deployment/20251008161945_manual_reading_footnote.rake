namespace :after_party do
  desc 'Deployment task: manual_reading_footnote'
  task manual_reading_footnote: :environment do
    puts "Running deploy task 'manual_reading_footnote'"

    Comparison::Footnote.find_or_create_by!(key: 'manual_readings') do |footnote|
      footnote.label = 'mr'
      footnote.description = 'schools where manual readings have been used'
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
