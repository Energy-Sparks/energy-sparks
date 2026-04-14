# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: british_gas_deletions'
  task british_gas_deletions: :environment do
    puts "Running deploy task 'british_gas_deletions'"

    # Date from which we are removing all data and meter attributes
    removal_date = Date.new(2025, 4, 1)

    # Delete all data supplied by British Gas from the removal date
    config = AmrDataFeedConfig.where(identifier: 'british-gas-new')
    AmrDataFeedReading.where(amr_data_feed_config: config).where(created_at: removal_date..).delete_all

    # Find any meter attributes that force substitution of bad data for British Gas meters
    # that have been created since the removal date, and mark as deleted.
    british_gas = DataSource.find(3)
    # rubocop:disable Rails/SkipsModelValidations
    british_gas.meters.main_meter.each do |meter|
      meter.meter_attributes.where(
        replaced_by_id: nil,
        deleted_by_id: nil,
        attribute_type: 'meter_corrections_override_bad_readings',
        created_at: removal_date..
      ).update_all(
        deleted_by_id: 947 # Me
      )
    end
    # rubocop:enable Rails/SkipsModelValidations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
