namespace :after_party do
  desc 'Deployment task: rename_frome_calendar_to_somerset'
  task rename_frome_calendar_to_somerset: :environment do
    puts "Running deploy task 'rename_frome_calendar_to_somerset'"

    # Put your task implementation HERE.
    frome_calendars = Calendar.where(title: 'Frome')

    if frome_calendars.any?
      frome_calendar = frome_calendars.first
      frome_calendar.update!(title: 'Somerset')
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
