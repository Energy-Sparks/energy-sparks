namespace :after_party do
  desc 'Deployment task: revise_npower_configuration'
  task revise_npower_configuration: :environment do
    puts "Running deploy task 'revise_npower_configuration'"

    config = AmrDataFeedConfig.find_by_identifier('npower-eon')
    if config.present?
      #12-Oct-23
      config.update!(date_format: '%d-%b-%y')
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
