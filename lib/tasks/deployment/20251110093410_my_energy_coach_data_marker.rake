namespace :after_party do
  desc 'Deployment task: my_energy_coach_data_marker'
  task my_energy_coach_data_marker: :environment do
    puts "Running deploy task 'my_energy_coach_data_marker'"

    identifier = 'my-energy-coach-data-marker'
    unless AmrDataFeedConfig.find_by_identifier(identifier)
      AmrDataFeedConfig.create!({
        identifier: identifier,
        description: 'My Energy Coach (Data Marker)',
        notes: 'Updated format with additional data marker columns',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MPAN',
        reading_date_field: 'ConsumptionDate',
        date_format: '%d/%m/%Y',
        header_example: 'siteRef,MPAN,ConsumptionDate,kWh_1,Data Marker,kWh_2,Data Marker,kWh_3,Data Marker,kWh_4,Data Marker,kWh_5,Data Marker,kWh_6,Data Marker,kWh_7,Data Marker,kWh_8,Data Marker,kWh_9,Data Marker,kWh_10,Data Marker,kWh_11,Data Marker,kWh_12,Data Marker,kWh_13,Data Marker,kWh_14,Data Marker,kWh_15,Data Marker,kWh_16,Data Marker,kWh_17,Data Marker,kWh_18,Data Marker,kWh_19,Data Marker,kWh_20,Data Marker,kWh_21,Data Marker,kWh_22,Data Marker,kWh_23,Data Marker,kWh_24,Data Marker,kWh_25,Data Marker,kWh_26,Data Marker,kWh_27,Data Marker,kWh_28,Data Marker,kWh_29,Data Marker,kWh_30,Data Marker,kWh_31,Data Marker,kWh_32,Data Marker,kWh_33,Data Marker,kWh_34,Data Marker,kWh_35,Data Marker,kWh_36,Data Marker,kWh_37,Data Marker,kWh_38,Data Marker,kWh_39,Data Marker,kWh_40,Data Marker,kWh_41,Data Marker,kWh_42,Data Marker,kWh_43,Data Marker,kWh_44,Data Marker,kWh_45,Data Marker,kWh_46,Data Marker,kWh_47,Data Marker,kWh_48,Data Marker',
        reading_fields: 'kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48'.split(',')
      })
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
