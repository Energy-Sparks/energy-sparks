namespace :after_party do
  desc 'Deployment task: Fix Term 6 description'
  task fix_term_six_description: :environment do
    puts "Running deploy task 'fix_term_six_description'"

    # Put your task implementation HERE.
    cet = CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2').first
    cet.update!(description: 'Summer Half Term 2') if cet.present?

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
