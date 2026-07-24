# frozen_string_literal: true

# rubocop:disable Layout/LineLength
namespace :after_party do
  desc 'Deployment task: british_gas_dc_da'
  task british_gas_dc_da: :environment do
    puts "Running deploy task 'british_gas_dc_da'"

    AmrDataFeedConfig.find_or_create_by!(identifier: 'british-gas-dc-da') do |config|
      config.assign_attributes(
        description: 'British Gas DC/DA',
        notes: 'Manual loading of data from British Gas DC/DA',
        number_of_header_rows: 1,
        mpan_mprn_field: 'mpxn',
        reading_date_field: 'reading_date',
        date_format: '%Y/%m/%d',
        header_example: %w[mpxn msn reading_date interval_1 interval_2 interval_3 interval_4 interval_5 interval_6 interval_7 interval_8 interval_9 interval_10 interval_11
                           interval_12 interval_13 interval_14 interval_15 interval_16 interval_17 interval_18 interval_19 interval_20 interval_21 interval_22 interval_23 interval_24 interval_25 interval_26 interval_27 interval_28 interval_29 interval_30 interval_31 interval_32 interval_33 interval_34 interval_35 interval_36 interval_37 interval_38 interval_39 interval_40 interval_41 interval_42 interval_43 interval_44 interval_45 interval_46 interval_47 interval_48 run_dt].join(','),
        reading_fields: %w[interval_1 interval_2 interval_3 interval_4 interval_5 interval_6 interval_7 interval_8 interval_9 interval_10 interval_11
                           interval_12 interval_13 interval_14 interval_15 interval_16 interval_17 interval_18 interval_19 interval_20 interval_21 interval_22 interval_23 interval_24 interval_25 interval_26 interval_27 interval_28 interval_29 interval_30 interval_31 interval_32 interval_33 interval_34 interval_35 interval_36 interval_37 interval_38 interval_39 interval_40 interval_41 interval_42 interval_43 interval_44 interval_45 interval_46 interval_47 interval_48]
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Layout/LineLength
