namespace :after_party do
  desc 'Deployment task: create_british_gas_data_feed_config'
  task create_british_gas_data_feed_config: :environment do
    puts "Running deploy task 'create_british_gas_data_feed_config'"

    new_config = {}
    new_config['description'] = 'British Gas'
    new_config['identifier'] = 'british-gas'
    new_config['number_of_header_rows'] = 1
    new_config['date_format'] = '%d/%m/%y'
    new_config['mpan_mprn_field'] = 'meter_identifier'
    new_config['reading_date_field'] = 'read_date'
    new_config['reading_fields'] = 'hh01,hh02,hh03,hh04,hh05,hh06,hh07,hh08,hh09,hh10,hh11,hh12,hh13,hh14,hh15,hh16,hh17,hh18,hh19,hh20,hh21,hh22,hh23,hh24,hh25,hh26,hh27,hh28,hh29,hh30,hh31,hh32,hh33,hh34,hh35,hh36,hh37,hh38,hh39,hh40,hh41,hh42,hh43,hh44,hh45,hh46,hh47,hh48'.split(',')
    new_config['header_example'] = 'meter_identifier,serial_number,read_date,hh01,hh02,hh03,hh04,hh05,hh06,hh07,hh08,hh09,hh10,hh11,hh12,hh13,hh14,hh15,hh16,hh17,hh18,hh19,hh20,hh21,hh22,hh23,hh24,hh25,hh26,hh27,hh28,hh29,hh30,hh31,hh32,hh33,hh34,hh35,hh36,hh37,hh38,hh39,hh40,hh41,hh42,hh43,hh44,hh45,hh46,hh47,hh48'

    AmrDataFeedConfig.create!(new_config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
