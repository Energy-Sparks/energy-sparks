# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: new_british_gas_dcda_format'
  task new_british_gas_dcda_format: :environment do
    puts "Running deploy task 'new_british_gas_dcda_format'"

    AmrDataFeedConfig.transaction do
      AmrDataFeedConfig.find_by!(identifier: 'british-gas-dc-da').update!(
        description: 'British Gas DC/DA (Old)',
        identifier: 'british-gas-dc-da-old',
        enabled: false
      )
      # rubocop:disable Layout/LineLength
      AmrDataFeedConfig.find_or_create_by!(identifier: 'british-gas-dc-da') do |config|
        config.assign_attributes(
          description: 'British Gas DC/DA',
          notes: 'Manual loading of data from British Gas DC/DA. New Format',
          number_of_header_rows: 1,
          mpan_mprn_field: 'mpxn',
          reading_date_field: 'reading_date',
          date_format: '%d/%m/%Y',
          header_example: 'mpxn,msn,meter_read_type,reading_date,interval_1_indicator,interval_1,interval_2_indicator,interval_2,interval_3_indicator,interval_3,interval_4_indicator,interval_4,interval_5_indicator,interval_5,interval_6_indicator,interval_6,interval_7_indicator,interval_7,interval_8_indicator,interval_8,interval_9_indicator,interval_9,interval_10_indicator,interval_10,interval_11_indicator,interval_11,interval_12_indicator,interval_12,interval_13_indicator,interval_13,interval_14_indicator,interval_14,interval_15_indicator,interval_15,interval_16_indicator,interval_16,interval_17_indicator,interval_17,interval_18_indicator,interval_18,interval_19_indicator,interval_19,interval_20_indicator,interval_20,interval_21_indicator,interval_21,interval_22_indicator,interval_22,interval_23_indicator,interval_23,interval_24_indicator,interval_24,interval_25_indicator,interval_25,interval_26_indicator,interval_26,interval_27_indicator,interval_27,interval_28_indicator,interval_28,interval_29_indicator,interval_29,interval_30_indicator,interval_30,interval_31_indicator,interval_31,interval_32_indicator,interval_32,interval_33_indicator,interval_33,interval_34_indicator,interval_34,interval_35_indicator,interval_35,interval_36_indicator,interval_36,interval_37_indicator,interval_37,interval_38_indicator,interval_38,interval_39_indicator,interval_39,interval_40_indicator,interval_40,interval_41_indicator,interval_41,interval_42_indicator,interval_42,interval_43_indicator,interval_43,interval_44_indicator,interval_44,interval_45_indicator,interval_45,interval_46_indicator,interval_46,interval_47_indicator,interval_47,interval_48_indicator,interval_48,run_dt',
          reading_fields: %w[interval_1 interval_2 interval_3 interval_4 interval_5 interval_6 interval_7 interval_8 interval_9 interval_10 interval_11
                             interval_12 interval_13 interval_14 interval_15 interval_16 interval_17 interval_18 interval_19 interval_20 interval_21 interval_22 interval_23 interval_24 interval_25 interval_26 interval_27 interval_28 interval_29 interval_30 interval_31 interval_32 interval_33 interval_34 interval_35 interval_36 interval_37 interval_38 interval_39 interval_40 interval_41 interval_42 interval_43 interval_44 interval_45 interval_46 interval_47 interval_48]
        )
      end
      # rubocop:enable Layout/LineLength
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Metrics/BlockLength
