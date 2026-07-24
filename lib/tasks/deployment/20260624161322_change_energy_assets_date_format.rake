# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: change_energy_assets_date_format'
  task change_energy_assets_date_format: :environment do
    puts "Running deploy task 'change_energy_assets_date_format'"

    AmrDataFeedConfig.find_by(identifier: 'energy-assets2')&.update!(date_format: '%Y-%m-%d')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
