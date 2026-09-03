# frozen_string_literal: true

namespace :after_party do # rubocop:disable Metrics/BlockLength
  desc 'Deployment task: bryt_new_format'
  task bryt_new_format: :environment do
    puts "Running deploy task 'bryt_new_format'"

    AmrDataFeedConfig.find_or_create_by!(identifier: 'bryt-new') do |config|
      config.assign_attributes(
        description: 'Bryt New',
        notes: 'New row per reading format',
        number_of_header_rows: 4,
        row_per_reading: true,
        mpan_mprn_field: 'MPAN',
        reading_date_field: 'Date BST',
        date_format: '%d/%m/%Y',
        positional_index: true,
        period_field: 'Period BST',
        reading_fields: ['Consumption AI'],
        reading_status_fields: ['Actual / estimated AI'],
        column_row_filters: { 'Consumption AI' => '^$' }, # ignore empty rows, reduce warnings
        header_example: 'MPAN,Billing group,Date BST,Period BST,Line loss factor,Transmission loss multiplier,' \
                        'Consumption MSP,Consumption GSP,Consumption NBP,Consumption AI,Consumption AE,' \
                        'Consumption RI,Consumption RE,Actual / estimated AI,Actual / estimated AE,' \
                        'Actual / estimated RI,Actual / estimated RE,Creation time AI,Creation time AE,' \
                        'Creation time RI,Creation time RE'
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
