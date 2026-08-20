# frozen_string_literal: true

namespace :after_party do # rubocop:disable Metrics/BlockLength
  desc 'Deployment task: add_reading_status_fields_to_configs'
  task add_reading_status_fields_to_configs: :environment do # rubocop:disable Metrics/BlockLength
    puts "Running deploy task 'add_reading_status_fields_to_configs'"

    british_gas_dc_da_configs = AmrDataFeedConfig.where(identifier: %w[british-gas-dc-da british-gas-dc-da-electricity])
    british_gas_dc_da_configs.each do |config|
      # interval_1_indicator...interval_48_indicator. Values: Empty, A, C, E
      config.update!(reading_status_fields: Array.new(48) { |i| "interval_#{i + 1}_indicator" })
    end

    brook_green_electricity = AmrDataFeedConfig.find_by(identifier: 'brook-green-electricity')
    brook_green_electricity&.update!(reading_status_fields: Array.new(48) { |i| "ReadTypeHH#{i + 1}" })

    clarity_reporting = AmrDataFeedConfig.find_by(identifier: 'clarity-reporting')
    clarity_reporting&.update!(reading_status_fields: Array.new(48) do |hh|
      "#{TimeOfDay.time_of_day_from_halfhour_index(hh)} Flag"
    end)

    crown_electricity = AmrDataFeedConfig.find_by(identifier: 'crown-electricity')
    if crown_electricity
      reading_status_fields = crown_electricity.header_example.split(',').select { |c| c.include?('Estimated') }
      crown_electricity.update!(reading_status_fields:)
    end

    datavision_custom = AmrDataFeedConfig.find_by(identifier: 'datavision-custom')
    datavision_custom&.update!(reading_status_fields: ['Data Quality'])

    drax_portal_new = AmrDataFeedConfig.find_by(identifier: 'drax-portal-new')
    # CSV has 2 blocks of columns called HH1-HH48. First are readings, second are status flags
    # Indicate use of repeated names
    drax_portal_new&.update!(reading_status_fields: Array.new(48) { |i| "HH#{i + 1}" }, repeated_names: true)

    edf_configs = AmrDataFeedConfig.where(identifier: %w[edf edf-historic edf-historic2])
    edf_configs.find_each do |config|
      # Repeated columns called 'Type'
      config.update!(reading_status_fields: ['Type'])
    end

    edf_row_per_reading = AmrDataFeedConfig.find_by(identifier: 'edf-20260109')
    # row per reading, each labelled as Actual or Estimated
    edf_row_per_reading&.update!(reading_status_fields: ['ReadType'])

    imserv_datavision = AmrDataFeedConfig.find_by(identifier: 'imserv-datavision')
    # single status for whole day, values: A, E, -
    imserv_datavision&.update!(reading_status_fields: ['DQ Flag'])

    mec_configs = AmrDataFeedConfig.where(identifier: %w[my-energy-coach-data-marker my-energy-coach-site-name])
    mec_configs.find_each do |config|
      # Repeated columns called 'Data Marker'. Values: 'A'
      config.update!(reading_status_fields: ['Data Marker'])
    end

    npower_eon = AmrDataFeedConfig.find_by(identifier: 'npower-eon')
    npower_eon&.update!(reading_status_fields: ['colStatuskwh'])

    perse = AmrDataFeedConfig.find_by(identifier: 'perse')
    # UT1..UT48
    perse&.update!(reading_status_fields: Array.new(48) { |i| "UT#{i + 1}" })

    sse1 = AmrDataFeedConfig.find_by(identifier: 'sse1')
    sse1&.update!(reading_status_fields: Array.new(48) { |hh| "#{TimeOfDay.time_of_day_from_halfhour_index(hh)} Flag" })

    stark_configs = AmrDataFeedConfig.where(identifier: %w[smartestenergy-stark stark-portal-electricity])
    stark_configs.each do |config|
      config.update!(reading_status_fields: ['Est'])
    end

    tgp_hh_manual = AmrDataFeedConfig.find_by(identifier: 'tgp-hh-manual')
    # Override default checks to treat 'Yes' as estimated
    tgp_hh_manual&.update!(reading_status_fields: ['Actual or Estimate'], estimate_flags: ['Yes'])

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
