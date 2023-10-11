namespace :after_party do
  desc 'Deployment task: npower_eon_format'
  task npower_eon_format: :environment do
    puts "Running deploy task 'npower_eon_format'"

    identifier = 'npower-eon'
    config = {}
    config['identifier'] = identifier
    config['description'] = 'NPower Eon Manual Request'
    config['notes'] = 'For processing the NPower/Eon weekly download request after saving as CSV'
    config['header_example'] = 'mpan,rdate,TotalConsumptionKwh,MaxDemand,colStatuskwh,Kwh1,Kwh2,Kwh3,Kwh4,Kwh5,Kwh6,Kwh7,Kwh8,Kwh9,Kwh10,Kwh11,Kwh12,Kwh13,Kwh14,Kwh15,Kwh16,Kwh17,Kwh18,Kwh19,Kwh20,Kwh21,Kwh22,Kwh23,Kwh24,Kwh25,Kwh26,Kwh27,Kwh28,Kwh29,Kwh30,Kwh31,Kwh32,Kwh33,Kwh34,Kwh35,Kwh36,Kwh37,Kwh38,Kwh39,Kwh40,Kwh41,Kwh42,Kwh43,Kwh44,Kwh45,Kwh46,Kwh47,Kwh48'
    config['number_of_header_rows'] = 1
    config['date_format'] = '%d/%m/%Y'
    config['mpan_mprn_field'] = 'mpan'
    config['reading_date_field'] = 'rdate'
    config['reading_fields'] = 'Kwh1,Kwh2,Kwh3,Kwh4,Kwh5,Kwh6,Kwh7,Kwh8,Kwh9,Kwh10,Kwh11,Kwh12,Kwh13,Kwh14,Kwh15,Kwh16,Kwh17,Kwh18,Kwh19,Kwh20,Kwh21,Kwh22,Kwh23,Kwh24,Kwh25,Kwh26,Kwh27,Kwh28,Kwh29,Kwh30,Kwh31,Kwh32,Kwh33,Kwh34,Kwh35,Kwh36,Kwh37,Kwh38,Kwh39,Kwh40,Kwh41,Kwh42,Kwh43,Kwh44,Kwh45,Kwh46,Kwh47,Kwh48'.split(',')

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: identifier)
    if amr_data_feed_config
      amr_data_feed_config.update!(config)
    else
      AmrDataFeedConfig.create!(config)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
