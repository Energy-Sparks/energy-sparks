# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_alert_type_rating_show_config'
  task add_alert_type_rating_show_config: :environment do
    puts "Running deploy task 'add_alert_type_rating_show_config'"

    # Put your task implementation HERE.
    AlertType.where(fuel_type: nil).update(show_ratings: false)
    AlertType.where(title: 'Turn heating on/off').update(show_ratings: false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190128145154'
  end
end
