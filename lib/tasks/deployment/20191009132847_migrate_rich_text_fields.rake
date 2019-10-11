namespace :after_party do
  desc 'Deployment task: migrate_rich_text_fields'
  task migrate_rich_text_fields: :environment do
    puts "Running deploy task 'migrate_rich_text_fields'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do
      EquivalenceTypeContentVersion.all.each do |etcv|
        etcv.update!(equivalence: etcv._equivalence)
      end

      Observation.all.each do |observation|
        observation.update!(description: observation._description)
      end

      AlertTypeRatingContentVersion.all.each do |atrcv|
        atrcv.update!(email_content: atrcv._email_content)
        atrcv.update!(find_out_more_content: atrcv._find_out_more_content)
        atrcv.update!(management_priorities_title: atrcv._management_priorities_title)
        atrcv.update!(management_dashboard_title: atrcv._management_dashboard_title)
        atrcv.update!(public_dashboard_title: atrcv._public_dashboard_title)
        atrcv.update!(pupil_dashboard_title: atrcv._pupil_dashboard_title)
        atrcv.update!(teacher_dashboard_title: atrcv._teacher_dashboard_title)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end