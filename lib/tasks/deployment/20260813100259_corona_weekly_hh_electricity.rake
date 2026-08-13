# frozen_string_literal: true

# rubocop:disable Layout/LineLength
namespace :after_party do
  desc 'Deployment task: Corona weekly hh electricity data'
  task corona_weekly_hh_electricity: :environment do
    puts "Running deploy task 'corona_weekly_hh_electricity'"

    AmrDataFeedConfig.find_or_create_by!(identifier: 'corona-weekly-hh-electricity') do |config|
      config.assign_attributes(
        description: 'Corona Weekly HH electricity data',
        notes: '',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MPAN_CORE',
        reading_date_field: 'SETTLEMENT_DATETIME',
        date_format: '%d/%m/%Y',
        header_example: 'MPAN_CORE,SETTLEMENT_DATETIME,ID1,ID2,ID3,ID4,ID5,ID6,ID7,ID8,ID9,ID10,ID11,ID12,ID13,ID14,ID15,ID16,ID17,ID18,ID19,ID20,ID21,ID22,ID23,ID24,ID25,ID26,ID27,ID28,ID29,ID30,ID31,ID32,ID33,ID34,ID35,ID36,ID37,ID38,ID39,ID40,ID41,ID42,ID43,ID44,ID45,ID46,ID47,ID48',
        reading_fields: 'ID1,ID2,ID3,ID4,ID5,ID6,ID7,ID8,ID9,ID10,ID11,ID12,ID13,ID14,ID15,ID16,ID17,ID18,ID19,ID20,ID21,ID22,ID23,ID24,ID25,ID26,ID27,ID28,ID29,ID30,ID31,ID32,ID33,ID34,ID35,ID36,ID37,ID38,ID39,ID40,ID41,ID42,ID43,ID44,ID45,ID46,ID47,ID48'.split(',')
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Layout/LineLength
