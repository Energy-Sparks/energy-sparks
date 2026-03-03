namespace :after_party do
  desc 'Deployment task: edf_config_update_20260109'
  task edf_config_update_20260109: :environment do
    puts "Running deploy task 'edf_config_update_20260109'"

    AmrDataFeedConfig.transaction do
      edf_historic = AmrDataFeedConfig.find_by!(identifier: 'edf-historic')
      edf_historic.update!(number_of_header_rows: 2) # first line has "sep=",
      AmrDataFeedConfig.find_by!(identifier: 'edf').update(identifier: 'edf-20260109')
      attributes = { description: 'EDF',
                     number_of_header_rows: 2,
                     mpan_mprn_field: edf_historic.mpan_mprn_field,
                     reading_date_field: edf_historic.reading_date_field,
                     date_format: edf_historic.date_format,
                     header_example: edf_historic.header_example,
                     reading_fields: edf_historic.reading_fields,
                     owned_by_id: edf_historic.owned_by_id }
      edf = AmrDataFeedConfig.find_or_create_by!(identifier: 'edf') { |config| config.assign_attributes(attributes) }
      edf.update!(attributes)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
