# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_reading_status_fields_to_configs'
  task add_reading_status_fields_to_configs: :environment do
    puts "Running deploy task 'add_reading_status_fields_to_configs'"

    stark = AmrDataFeedConfig.find_by(identifier: 'smartestenergy-stark')
    # single status for whole day, values: A, E, -
    stark&.update!(reading_status_fields: ['Est'])

    edf = AmrDataFeedConfig.find_by(identifier: 'edf')
    # status per half hour, but column name is repeated so specify once. All values will be found.
    # Actual values: Actual, Estimated
    edf&.update!(reading_status_fields: ['Type'])

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
