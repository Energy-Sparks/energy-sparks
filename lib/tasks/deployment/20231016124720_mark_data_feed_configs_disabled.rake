namespace :after_party do
  desc 'Deployment task: mark_data_feed_configs_disabled'
  task mark_data_feed_configs_disabled: :environment do
    puts "Running deploy task 'mark_data_feed_configs_disabled'"

    TO_DISABLE = ['sheffield-gas', 'gdst-gas', 'energy-assets-channel', 'sheffield-historical-gas', 'frome-historical', 'gdst-historic-electricity', 'gdst-electricity', 'frome', 'gdst-electricity2', 'wme-electricity', 'highlands-historic', 'edf-format-2', 'east-sussex-gas', 'highlands']

    AmrDataFeedConfig.where(identifier: TO_DISABLE).update_all(enabled: false)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
