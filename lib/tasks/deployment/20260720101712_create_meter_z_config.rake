# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_meter_z_config'
  task create_meter_z_config: :environment do
    puts "Running deploy task 'create_meter_z_config'"

    AmrDataFeedConfig.create!(description: 'MeterZ',
                              identifier: 'meter-z',
                              date_format: 'n/a',
                              mpan_mprn_field: 'n/a',
                              reading_date_field: 'n/a',
                              reading_fields: [],
                              process_type: :other_api,
                              source_type: :api)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
