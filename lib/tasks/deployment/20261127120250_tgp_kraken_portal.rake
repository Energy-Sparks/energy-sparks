# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: tgp_kraken_portal'
  task tgp_kraken_portal: :environment do
    puts "Running deploy task 'tgp_kraken_portal'"

    reading_fields = '00:00 - 00:30,00:30 - 01:00,01:00 - 01:30,01:30 - 02:00,02:00 - 02:30,02:30 - 03:00,' \
                     '03:00 - 03:30,03:30 - 04:00,04:00 - 04:30,04:30 - 05:00,05:00 - 05:30,05:30 - 06:00,' \
                     '06:00 - 06:30,06:30 - 07:00,07:00 - 07:30,07:30 - 08:00,08:00 - 08:30,08:30 - 09:00,' \
                     '09:00 - 09:30,09:30 - 10:00,10:00 - 10:30,10:30 - 11:00,11:00 - 11:30,11:30 - 12:00,' \
                     '12:00 - 12:30,12:30 - 13:00,13:00 - 13:30,13:30 - 14:00,14:00 - 14:30,14:30 - 15:00,' \
                     '15:00 - 15:30,15:30 - 16:00,16:00 - 16:30,16:30 - 17:00,17:00 - 17:30,17:30 - 18:00,' \
                     '18:00 - 18:30,18:30 - 19:00,19:00 - 19:30,19:30 - 20:00,20:00 - 20:30,20:30 - 21:00,' \
                     '21:00 - 21:30,21:30 - 22:00,22:00 - 22:30,22:30 - 23:00,23:00 - 23:30,23:30 - 00:00'
    AmrDataFeedConfig
      .find_or_initialize_by(identifier: 'tgp-kraken-portal')
      .update!(
        description: 'TGP Kraken portal',
        notes: '',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MPxN',
        reading_date_field: 'Date',
        date_format: '%d/%m/%Y',
        header_example: 'Organisation Name,Account Number,MPxN,Date,Unit,Reading Direction,Quality,Total Consumption,' \
                        "#{reading_fields}",
        reading_fields: reading_fields.split(','),
        reading_status_fields: ['Quality'],
        estimate_flags: %w[ESTIMATE ESTIMATED] # example has ACTUAL only so guessing these will be used for estimated
      )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
