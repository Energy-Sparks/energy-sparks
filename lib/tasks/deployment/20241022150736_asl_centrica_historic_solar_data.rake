namespace :after_party do
  desc 'Deployment task: asl_centrica_historic_solar_data'
  task asl_centrica_historic_solar_data: :environment do
    puts "Running deploy task 'asl_centrica_historic_solar_data'"

    config = {}
    config['description'] = 'ASL Centrica Historic Solar'
    config['identifier'] = 'asl-centrica-solar'
    config['notes'] = 'Format for loading historical solar data for Centrica. Uses serial numbers'
    config['number_of_header_rows'] = 0
    config['date_format'] = '%H:%M:%S %a %d/%m/%Y'
    times = (0..23).flat_map { |h| %w[00 30].freeze.map { |m| "#{h.to_s.rjust(2, '0')}#{m}" } }
    config['reading_fields'] = times.map { |t| "import#{t}" }
    config['header_example'] = 'reference,meter,time,total_import,total_export,' \
                               "#{config['reading_fields'].zip(times.map { |t| "export#{t}" }).join'.'}"

    config['mpan_mprn_field'] = '' # must not be null, but wont be used
    config['msn_field'] = 'meter'
    config['lookup_by_serial_number'] = true
    config['reading_date_field'] = 'time'

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
