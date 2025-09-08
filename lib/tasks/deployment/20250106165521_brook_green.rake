namespace :after_party do
  desc 'Deployment task: Brook Green Portal'
  task brook_green: :environment do
    puts "Running deploy task 'brook_green'"

    identifier = 'brook-green'
    AmrDataFeedConfig.create!({
      identifier: identifier,
      description: 'Brook Green Portal',
      notes: '',
      number_of_header_rows: 1,
      mpan_mprn_field: 'meterPoint',
      reading_date_field: 'readDate_uk',
      date_format: '%d/%m/%Y',
      header_example: 'customerNumber,account,meterPoint,units,readDate_uk,consumptionNHH,consumptionHH_00_00_00,consumptionHH_00_30_00,consumptionHH_01_00_00,consumptionHH_01_30_00,consumptionHH_
02_00_00,consumptionHH_02_30_00,consumptionHH_03_00_00,consumptionHH_03_30_00,consumptionHH_04_00_00,consumptionHH_04_30_00,consumptionHH_05_00_00,consumptionHH_05_30_00,con
sumptionHH_06_00_00,consumptionHH_06_30_00,consumptionHH_07_00_00,consumptionHH_07_30_00,consumptionHH_08_00_00,consumptionHH_08_30_00,consumptionHH_09_00_00,consumptionHH_0
9_30_00,consumptionHH_10_00_00,consumptionHH_10_30_00,consumptionHH_11_00_00,consumptionHH_11_30_00,consumptionHH_12_00_00,consumptionHH_12_30_00,consumptionHH_13_00_00,cons
umptionHH_13_30_00,consumptionHH_14_00_00,consumptionHH_14_30_00,consumptionHH_15_00_00,consumptionHH_15_30_00,consumptionHH_16_00_00,consumptionHH_16_30_00,consumptionHH_17
_00_00,consumptionHH_17_30_00,consumptionHH_18_00_00,consumptionHH_18_30_00,consumptionHH_19_00_00,consumptionHH_19_30_00,consumptionHH_20_00_00,consumptionHH_20_30_00,consu
mptionHH_21_00_00,consumptionHH_21_30_00,consumptionHH_22_00_00,consumptionHH_22_30_00,consumptionHH_23_00_00,consumptionHH_23_30_00',
      reading_fields: 'consumptionHH_00_00_00,consumptionHH_00_30_00,consumptionHH_01_00_00,consumptionHH_01_30_00,consumptionHH_
02_00_00,consumptionHH_02_30_00,consumptionHH_03_00_00,consumptionHH_03_30_00,consumptionHH_04_00_00,consumptionHH_04_30_00,consumptionHH_05_00_00,consumptionHH_05_30_00,con
sumptionHH_06_00_00,consumptionHH_06_30_00,consumptionHH_07_00_00,consumptionHH_07_30_00,consumptionHH_08_00_00,consumptionHH_08_30_00,consumptionHH_09_00_00,consumptionHH_0
9_30_00,consumptionHH_10_00_00,consumptionHH_10_30_00,consumptionHH_11_00_00,consumptionHH_11_30_00,consumptionHH_12_00_00,consumptionHH_12_30_00,consumptionHH_13_00_00,cons
umptionHH_13_30_00,consumptionHH_14_00_00,consumptionHH_14_30_00,consumptionHH_15_00_00,consumptionHH_15_30_00,consumptionHH_16_00_00,consumptionHH_16_30_00,consumptionHH_17
_00_00,consumptionHH_17_30_00,consumptionHH_18_00_00,consumptionHH_18_30_00,consumptionHH_19_00_00,consumptionHH_19_30_00,consumptionHH_20_00_00,consumptionHH_20_30_00,consu
mptionHH_21_00_00,consumptionHH_21_30_00,consumptionHH_22_00_00,consumptionHH_22_30_00,consumptionHH_23_00_00,consumptionHH_23_30_00'.split(',')
    }) unless AmrDataFeedConfig.find_by_identifier(identifier)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
