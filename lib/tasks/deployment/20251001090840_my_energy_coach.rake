namespace :after_party do
  desc 'Deployment task: New NPower data management platform'
  task my_energy_coach: :environment do
    puts "Running deploy task 'my_energy_coach'"

    identifier = 'my-energy-coach'
    unless AmrDataFeedConfig.find_by_identifier(identifier)
      AmrDataFeedConfig.create!({
        identifier: identifier,
        description: 'My Energy Coach',
        notes: 'New NPower data management platform',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MPAN',
        reading_date_field: 'ConsumptionDate',
        date_format: '%d/%m/%Y',
        header_example: 'siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48',
        reading_fields: 'kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48'.split(',')
      })
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
