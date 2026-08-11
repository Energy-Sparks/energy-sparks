# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_reading_status_fields_to_configs'
  task add_reading_status_fields_to_configs: :environment do
    puts "Running deploy task 'add_reading_status_fields_to_configs'"

    stark = AmrDataFeedConfig.find_by(identifier: 'smartestenergy-stark')
    # single status for whole day, values: A, E, -
    stark&.update!(reading_status_fields: ['Est'])

    edf_configs = AmrDataFeedConfig.where(identifier: ['edf', 'edf-historic', 'edf-historic2'])
    edf_configs.find_each do |config|
      config.update!(reading_status_fields: ['Type'])
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
