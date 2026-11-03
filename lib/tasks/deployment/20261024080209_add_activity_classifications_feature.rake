# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_activity_classifications_feature'
  task add_activity_classifications_feature: :environment do
    puts "Running deploy task 'add_activity_classifications_feature'"

    Flipper.add(:activity_classifications)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
