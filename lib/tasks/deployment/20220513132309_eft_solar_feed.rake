namespace :after_party do
  desc 'Deployment task: eft_feed'
  task eft_solar_feed: :environment do
    puts "Running deploy task 'eft_solar_feed'"

    config = {}
    config['description'] = 'EfT Solar'
    config['identifier'] = 'eft-solar'
    config['number_of_header_rows'] = 0
    config['lookup_by_serial_number'] = true
    config['date_format'] = '%H:%M:%S %a %d/%m/%Y'
    config['mpan_mprn_field'] = ''
    config['reading_date_field'] = 'DateTime'
    config['meter_description_field'] = 'Description'
    config['msn_field'] = 'SerialNumber'
    config['units_field'] = 'units'
    config['reading_fields'] = 'kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48'.split(',')
    config['header_example'] = 'Description,SerialNumber,DateTime,import_total,export_total,kWh_1,_,kWh_2,_,kWh_3,_,kWh_4,_,kWh_5,_,kWh_6,_,kWh_7,_,kWh_8,_,kWh_9,_,kWh_10,_,kWh_11,_,kWh_12,_,kWh_13,_,kWh_14,_,kWh_15,_,kWh_16,_,kWh_17,_,kWh_18,_,kWh_19,_,kWh_20,_,kWh_21,_,kWh_22,_,kWh_23,_,kWh_24,_,kWh_25,_,kWh_26,_,kWh_27,_,kWh_28,_,kWh_29,_,kWh_30,_,kWh_31,_,kWh_32,_,kWh_33,_,kWh_34,_,kWh_35,_,kWh_36,_,kWh_37,_,kWh_38,_,kWh_39,_,kWh_40,_,kWh_41,_,kWh_42,_,kWh_43,_,kWh_44,_,kWh_45,_,kWh_46,_,kWh_47,_,kWh_48'

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
