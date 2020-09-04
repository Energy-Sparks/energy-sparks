namespace :after_party do
  desc 'Deployment task: add_generic_sheffield_gas'
  task add_generic_sheffield_gas: :environment do
    puts "Running deploy task 'add_generic_sheffield_gas'"

    # Put your task implementation HERE.
    sheffield_gas = AmrDataFeedConfig.find_by(identifier: 'sheffield-gas')

    energy_assets = sheffield_gas.attributes
    energy_assets.delete('id')
    energy_assets['description'] = "Energy Assets generic feed, based on Sheffield gas"
    energy_assets['identifier'] = 'energy-assets'

    AmrDataFeedConfig.create!(energy_assets)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end