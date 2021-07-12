namespace :after_party do
  desc 'Deployment task: rtone_variant_config'
  task rtone_variant_config: :environment do
    puts "Running deploy task 'rtone_variant_config'"

    config = {}
    config['description'] = "Rtone Variant API"
    config['identifier'] = 'rtone-variant-api'
    config['date_format'] = "%Y%m%d"
    config['mpan_mprn_field'] = 'N/A'
    config['reading_date_field'] = 'N/A'
    config['reading_fields'] = 'N/A'
    config['process_type'] = :rtone_variant_api
    config['source_type'] = :api

    fc = AmrDataFeedConfig.find_by_identifier('rtone-variant-api')
    if fc.nil?
      AmrDataFeedConfig.create!(config)
    else
      fc.update!(config)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
