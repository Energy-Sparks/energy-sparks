# rubocop:disable Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: crown_electricity'
  task crown_electricity: :environment do
    puts "Running deploy task 'crown_electricity'"

    identifier = 'crown-electricity'
    unless AmrDataFeedConfig.find_by_identifier(identifier)
      AmrDataFeedConfig.create!({
        identifier: identifier,
        description: 'Crown Electricity',
        notes: 'Crown Electricity format with quality indicators',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MPAN Core',
        reading_date_field: 'Read Date',
        date_format: '%d/%m/%Y',
        header_example: ['MPAN Core', 'Serial Num', 'Site Ref', 'Read Date', ' Consumption 00:00 AM', ' Estimated / Actual 00:00 AM', ' Consumption 00:30 AM', ' Estimated / Actual 00:30 AM',
                         ' Consumption 01:00 AM', ' Estimated / Actual 01:00 AM', ' Consumption 01:30 AM', ' Estimated / Actual 01:30 AM', ' Consumption 02:00 AM', ' Estimated / Actual 02:00 AM',
                         ' Consumption 02:30 AM', ' Estimated / Actual 02:30 AM', ' Consumption 03:00 AM', ' Estimated / Actual 03:00 AM', ' Consumption 03:30 AM', ' Estimated / Actual 03:30 AM',
                         ' Consumption 04:00 AM', ' Estimated / Actual 04:00 AM', ' Consumption 04:30 AM', ' Estimated / Actual 04:30 AM', ' Consumption 05:00 AM', ' Estimated / Actual 05:00 AM',
                         ' Consumption 05:30 AM', ' Estimated / Actual 05:30 AM', ' Consumption 06:00 AM', ' Estimated / Actual 06:00 AM', ' Consumption 06:30 AM', ' Estimated / Actual 06:30 AM',
                         ' Consumption 07:00 AM', ' Estimated / Actual 07:00 AM', ' Consumption 07:30 AM', ' Estimated / Actual 07:30 AM', ' Consumption 08:00 AM', ' Estimated / Actual 08:00 AM',
                         ' Consumption 08:30 AM', ' Estimated / Actual 08:30 AM', ' Consumption 09:00 AM', ' Estimated / Actual 09:00 AM', ' Consumption 09:30 AM', ' Estimated / Actual 09:30 AM',
                         ' Consumption 10:00 AM', ' Estimated / Actual 10:00 AM', ' Consumption 10:30 AM', ' Estimated / Actual 10:30 AM', ' Consumption 11:00 AM', ' Estimated / Actual 11:00 AM',
                         ' Consumption 11:30 AM', ' Estimated / Actual 11:30 AM', ' Consumption 12:00 PM', ' Estimated / Actual 12:00 PM', ' Consumption 12:30 PM', ' Estimated / Actual 12:30 PM',
                         ' Consumption 13:00 PM', ' Estimated / Actual 13:00 PM', ' Consumption 13:30 PM', ' Estimated / Actual 13:30 PM', ' Consumption 14:00 PM', ' Estimated / Actual 14:00 PM',
                         ' Consumption 14:30 PM', ' Estimated / Actual 14:30 PM', ' Consumption 15:00 PM', ' Estimated / Actual 15:00 PM', ' Consumption 15:30 PM', ' Estimated / Actual 15:30 PM',
                         ' Consumption 16:00 PM', ' Estimated / Actual 16:00 PM', ' Consumption 16:30 PM', ' Estimated / Actual 16:30 PM', ' Consumption 17:00 PM', ' Estimated / Actual 17:00 PM',
                         ' Consumption 17:30 PM', ' Estimated / Actual 17:30 PM', ' Consumption 18:00 PM', ' Estimated / Actual 18:00 PM', ' Consumption 18:30 PM', ' Estimated / Actual 18:30 PM',
                         ' Consumption 19:00 PM', ' Estimated / Actual 19:00 PM', ' Consumption 19:30 PM', ' Estimated / Actual 19:30 PM', ' Consumption 20:00 PM', ' Estimated / Actual 20:00 PM',
                         ' Consumption 20:30 PM', ' Estimated / Actual 20:30 PM', ' Consumption 21:00 PM', ' Estimated / Actual 21:00 PM', ' Consumption 21:30 PM', ' Estimated / Actual 21:30 PM',
                         ' Consumption 22:00 PM', ' Estimated / Actual 22:00 PM', ' Consumption 22:30 PM', ' Estimated / Actual 22:30 PM', ' Consumption 23:00 PM', ' Estimated / Actual 23:00 PM',
                         ' Consumption 23:30 PM', ' Estimated / Actual 23:30 PM', 'Time Change 1 Cons', 'Time Change 1 Est', 'Time Change 2 Cons', 'Time Change 2 Est', 'Total kWh'].join(','),
        reading_fields: [' Consumption 00:00 AM', ' Consumption 00:30 AM', ' Consumption 01:00 AM', ' Consumption 01:30 AM', ' Consumption 02:00 AM', ' Consumption 02:30 AM',
                         ' Consumption 03:00 AM', ' Consumption 03:30 AM', ' Consumption 04:00 AM', ' Consumption 04:30 AM', ' Consumption 05:00 AM', ' Consumption 05:30 AM',
                         ' Consumption 06:00 AM', ' Consumption 06:30 AM', ' Consumption 07:00 AM', ' Consumption 07:30 AM', ' Consumption 08:00 AM', ' Consumption 08:30 AM',
                         ' Consumption 09:00 AM', ' Consumption 09:30 AM', ' Consumption 10:00 AM', ' Consumption 10:30 AM', ' Consumption 11:00 AM', ' Consumption 11:30 AM',
                         ' Consumption 12:00 PM', ' Consumption 12:30 PM', ' Consumption 13:00 PM', ' Consumption 13:30 PM', ' Consumption 14:00 PM', ' Consumption 14:30 PM',
                         ' Consumption 15:00 PM', ' Consumption 15:30 PM', ' Consumption 16:00 PM', ' Consumption 16:30 PM', ' Consumption 17:00 PM', ' Consumption 17:30 PM',
                         ' Consumption 18:00 PM', ' Consumption 18:30 PM', ' Consumption 19:00 PM', ' Consumption 19:30 PM', ' Consumption 20:00 PM', ' Consumption 20:30 PM',
                         ' Consumption 21:00 PM', ' Consumption 21:30 PM', ' Consumption 22:00 PM', ' Consumption 22:30 PM', ' Consumption 23:00 PM', ' Consumption 23:30 PM']
      })
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Metrics/BlockLength
