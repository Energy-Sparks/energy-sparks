# frozen_string_literal: true

# rubocop:disable-next Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: end_date_for_british_gas_meters'
  task end_date_for_british_gas_meters: :environment do
    puts "Running deploy task 'end_date_for_british_gas_meters'"

    meters_with_issues = %w[
      7625110
      8224804
      10926005
      10926106
      10926308
      10926409
      10926510
      10926600
      11477209
      11477310
      11933602
      12352205
      12471202
      12471303
      12804304
      13610902
      13858007
      13941308
      13976103
      14009202
      14009303
      15436900
      15437206
      15525809
      15526003
      15526306
      16607300
      16763909
      16764204
      16831507
      45960408
      45976906
      50857407
      51137501
      51137602
      51137703
      51350400
      51377308
      51377409
      63417209
      67641807
      70597105
      70597408
      71066101
      71218502
      71788106
      73984610
      73985601
      74600705
      1885786003
      4189151201
      4228765303
      8817898510
      8827431501
      8850323806
      8866601710
      8915743702
      8919162208
      9116734904
      9140877207
      9140879301
      9146326200
      9146479304
      9147540409
      9167590403
      9206178104
      9207463209
      9209229200
      9209229301
      9217362007
      9219947506
      9306740009
      9314429802
      9315419007
      9334794804
      9335375710
      9354560802
      9357558303
      9357998006
      9359204805
      9375665205
      9378411907
      9383616704
      9387192507
    ]

    Meter.where(mpan_mprn: meters_with_issues).find_each do |meter|
      attributes = meter.meter_attributes.active.where(attribute_type: 'meter_corrections_readings_end_date')

      next if attributes.any? { |attribute| attribute.input_data == '11/07/2026' }

      meter.meter_attributes.create!(
        attribute_type: 'meter_corrections_readings_end_date',
        input_data: '11/07/2026',
        reason: 'Bulk add due to British Gas issues'
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
