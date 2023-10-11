namespace :after_party do
  desc 'Deployment task: create_drax_portal_data_feed'
  task create_drax_portal_data_feed: :environment do
    puts "Running deploy task 'create_drax_portal_data_feed'"

    config = {}
    config['description'] = "Drax Portal"
    config['identifier'] = 'drax-portal'
    config['number_of_header_rows'] = 1
    config['date_format'] = "%Y-%m-%d" # e.g. 2023-08-01
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'Date'
    config['reading_fields'] = 'HH1,HH2,HH3,HH4,HH5,HH6,HH7,HH8,HH9,HH10,HH11,HH12,HH13,HH14,HH15,HH16,HH17,HH18,HH19,HH20,HH21,HH22,HH23,HH24,HH25,HH26,HH27,HH28,HH29,HH30,HH31,HH32,HH33,HH34,HH35,HH36,HH37,HH38,HH39,HH40,HH41,HH42,HH43,HH44,HH45,HH46,HH47,HH48'.split(',')
    config['header_example'] = "MPAN,Date,Total,HH1,HH2,HH3,HH4,HH5,HH6,HH7,HH8,HH9,HH10,HH11,HH12,HH13,HH14,HH15,HH16,HH17,HH18,HH19,HH20,HH21,HH22,HH23,HH24,HH25,HH26,HH27,HH28,HH29,HH30,HH31,HH32,HH33,HH34,HH35,HH36,HH37,HH38,HH39,HH40,HH41,HH42,HH43,HH44,HH45,HH46,HH47,HH48,HH49,HH50"

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end