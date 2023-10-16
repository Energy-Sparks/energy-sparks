namespace :after_party do
  desc 'Deployment task: update_data_feed_config_identifiers'
  task update_data_feed_config_identifiers: :environment do
    puts "Running deploy task 'update_data_feed_config_identifiers'"

    RENAMES = {
      'sheffield' => 'npower-ia',
      'sse-dukefield-energy' => 'sse1',
      'sse' => 'sse2',
      'stark-portal' => 'stark-portal-electricity',
      'eon' => 'generic1',
      'gdst-historic-gas' => 'generic2',
      'orsis-historic' => 'orsis-portal'
    }

    RENAMES.each do |old_identifier, new_identifier|
      amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: old_identifier)
      if amr_data_feed_config
        amr_data_feed_config.update!(identifier: new_identifier)
      else
        puts "Unable to find #{old_identifier}"
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
