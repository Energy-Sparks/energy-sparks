# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: brook_green_electricity'
  task brook_green_electricity: :environment do
    puts "Running deploy task 'brook_green_electricity'"

    AmrDataFeedConfig.where(identifier: 'brook-green').update(
      identifier: 'brook-green-gas',
      description: 'Brook Green Portal (Gas)'
    )

    # rubocop:disable Layout/LineLength
    AmrDataFeedConfig.find_or_create_by!(identifier: 'brook-green-electricity') do |config|
      config.assign_attributes(
        description: 'Brook Green Portal (Electricity)',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MeterPoint',
        reading_date_field: 'ReadDateUK',
        date_format: '%d/%m/%Y',
        units_field: 'Unit',
        header_example: 'CustomerNumber,Account,MeterPoint,MeasurementType,ProfileClass,Unit,ReadDateUK,ReadTypeHH1,HH1,ReadTypeHH2,HH2,ReadTypeHH3,HH3,ReadTypeHH4,HH4,ReadTypeHH5,HH5,ReadTypeHH6,HH6,ReadTypeHH7,HH7,ReadTypeHH8,HH8,ReadTypeHH9,HH9,ReadTypeHH10,HH10,ReadTypeHH11,HH11,ReadTypeHH12,HH12,ReadTypeHH13,HH13,ReadTypeHH14,HH14,ReadTypeHH15,HH15,ReadTypeHH16,HH16,ReadTypeHH17,HH17,ReadTypeHH18,HH18,ReadTypeHH19,HH19,ReadTypeHH20,HH20,ReadTypeHH21,HH21,ReadTypeHH22,HH22,ReadTypeHH23,HH23,ReadTypeHH24,HH24,ReadTypeHH25,HH25,ReadTypeHH26,HH26,ReadTypeHH27,HH27,ReadTypeHH28,HH28,ReadTypeHH29,HH29,ReadTypeHH30,HH30,ReadTypeHH31,HH31,ReadTypeHH32,HH32,ReadTypeHH33,HH33,ReadTypeHH34,HH34,ReadTypeHH35,HH35,ReadTypeHH36,HH36,ReadTypeHH37,HH37,ReadTypeHH38,HH38,ReadTypeHH39,HH39,ReadTypeHH40,HH40,ReadTypeHH41,HH41,ReadTypeHH42,HH42,ReadTypeHH43,HH43,ReadTypeHH44,HH44,ReadTypeHH45,HH45,ReadTypeHH46,HH46,ReadTypeHH47,HH47,ReadTypeHH48,HH48,ReadTypeHH49,HH49,ReadTypeHH50,HH50',
        reading_fields: 'HH1,HH2,HH3,HH4,HH5,HH6,HH7,HH8,HH9,HH10,HH11,HH12,HH13,HH14,HH15,HH16,HH17,HH18,HH19,HH20,HH21,HH22,HH23,HH24,HH25,HH26,HH27,HH28,HH29,HH30,HH31,HH32,HH33,HH34,HH35,HH36,HH37,HH38,HH39,HH40,HH41,HH42,HH43,HH44,HH45,HH46,HH47,HH8'.split(',')
      )
    end
    # rubocop:enable Layout/LineLength

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
