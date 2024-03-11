namespace :after_party do
  desc 'Deployment task: ems_format'
  task ems_format: :environment do
    puts "Running deploy task 'ems_format'"

    config = {}
    config['description'] = "EMS Gas (CNS) format"
    config['identifier'] = 'ems-gas-cns'
    config['notes'] = "CNS format files containing m3 readings that are automatically convered to kWh when loaded"
    config['number_of_header_rows'] = 1
    config['row_per_reading'] = true
    config['date_format'] = "%Y%m%d" # 20240212

    config['header_example'] = "Type,MPRN,Serial,Date,Time,Reading,Ignore"
    config['mpan_mprn_field'] = 'MPRN'
    config['reading_date_field'] = 'Date'
    config['reading_time_field'] = 'Time'
    config['msn_field'] = 'Serial'
    config['reading_fields'] = ["Reading"]
    config['convert_to_kwh'] = true
    config['positional_index'] = true

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
