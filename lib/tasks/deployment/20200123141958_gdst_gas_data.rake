namespace :after_party do
  desc 'Deployment task: gdst_gas_data'
  task gdst_gas_data: :environment do
    puts "Running deploy task 'gdst_gas_data'"

    sheffield_feed = AmrDataFeedConfig.find_by!(identifier: 'sheffield-gas')

    AmrDataFeedConfig.create!(
      sheffield_feed.attributes.except("id", "created_at", "updated_at").merge(
        "description" => 'GDST gas',
        "identifier" => 'gdst-gas'
      )
    )

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
