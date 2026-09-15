namespace :after_party do
  desc 'Deployment task: update_brook_green_gas_config'
  task update_brook_green_gas_config: :environment do
    puts "Running deploy task 'update_brook_green_gas_config'"

    old = AmrDataFeedConfig.find_by!(identifier: 'brook-green-gas')
    old.update!(identifier: 'brook-green-gas-old', description: 'Brook Green Portal Old (Gas)', enabled: false)
    AmrDataFeedConfig.find_or_create_by!(identifier: 'brook-green-gas') do |config|
      config.assign_attributes(
        description: 'Brook Green Portal (Gas)',
        notes: 'New format September 2026',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MeterPoint',
        reading_date_field: 'ReadDateUK',
        date_format: '%Y-%m-d',
        header_example: 'CompanyName,Account,MeterPoint,Unit,ReadDateUK,HH1,HH2,HH3,HH4,HH5,HH6,HH7,HH8,HH9,HH10,' \
                        'HH11,HH12,HH13,HH14,HH15,HH16,HH17,HH18,HH19,HH20,HH21,HH22,HH23,HH24,HH25,HH26,HH27,HH28,' \
                        'HH29,HH30,HH31,HH32,HH33,HH34,HH35,HH36,HH37,HH38,HH39,HH40,HH41,HH42,HH43,HH44,HH45,HH46,' \
                        'HH47,HH48,HH49,HH50',
        reading_fields: 'HH1,HH2,HH3,HH4,HH5,HH6,HH7,HH8,HH9,HH10,HH11,HH12,HH13,HH14,HH15,HH16,HH17,HH18,HH19,HH20,' \
                        'HH21,HH22,HH23,HH24,HH25,HH26,HH27,HH28,HH29,HH30,HH31,HH32,HH33,HH34,HH35,HH36,HH37,HH38,' \
                        'HH39,HH40,HH41,HH42,HH43,HH44,HH45,HH46,HH47,HH48'.split(','),
        owned_by_id: old.owned_by_id
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
