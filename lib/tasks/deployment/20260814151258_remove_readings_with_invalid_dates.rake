# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: remove_readings_with_invalid_dates'
  task remove_readings_with_invalid_dates: :environment do
    puts "Running deploy task 'remove_readings_with_invalid_dates'"

    # Where reading date is two digits
    # When parsed these are treated as dates in current month
    #
    # ~ 5 records
    AmrDataFeedReading.where("reading_date ~ '^\\d{2}$'").delete_all

    # Where reading date is five digits.
    # Excel internally stores dates as a sequential number starting from 1/1/1900.
    # These will be result of errors when manually converting/reformatting Excel data to CSV
    #
    # When parsed these are turned into future dates.
    #
    # Date.parse('42364') => '2042-12-30'
    #
    # ~ 1080 records
    AmrDataFeedReading.where("reading_date ~ '^\\d{5}$'").delete_all

    # When reading date is a floating point number, e.g. 1.11
    # Likely to be caused by loading data with incorrect format
    #
    # When parsed becomes day in current month.
    # Date.parse('1.11') => '2042-08-11'
    #
    # ~ 6 records
    AmrDataFeedReading.where("reading_date ~ '^\\d{1,2}\\.\\d{1,2}$'").delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
