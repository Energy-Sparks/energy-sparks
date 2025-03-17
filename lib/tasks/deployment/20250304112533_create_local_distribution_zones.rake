namespace :after_party do
  desc 'Deployment task: create_local_distribution_zones'
  task create_local_distribution_zones: :environment do
    puts "Running deploy task 'create_local_distribution_zones'"

    # zones and publication IDs from https://data.nationalgas.com/find-gas-data
    [
      [:EA, :PUBOB4507, 'East Anglia'],
      [:EM, :PUBOB4508, 'East Midlands'],
      [:NO, :PUBOB4509, 'Northern'],
      [:NE, :PUBOB4510, 'North East'],
      [:NT, :PUBOB4511, 'North Thames'],
      [:NW, :PUBOB4512, 'North West'],
      [:SC, :PUBOB4513, 'Scotland'],
      [:SO, :PUBOB4514, 'Southern'],
      [:SE, :PUBOB4515, 'South East'],
      [:SW, :PUBOB4516, 'South West'],
      [:WM, :PUBOB4517, 'West Midlands'],
      [:WN, :PUBOB4518, 'Wales North'],
      [:WS, :PUBOB4519, 'Wales South'],
      [:LO, :PUBOB4521, 'Oban'],
      [:LS, :PUBOB4522, 'Stranraer'],
      [:LC, :PUBOBJ1660, 'Campbeltown'],
      [:LT, :PUBOBJ1661, 'Thurso'],
      [:LW, :PUBOBJ1662, 'Wick']
    ].each do |code, publication_id, name|
      LocalDistributionZone.create!(name:, code:, publication_id:)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
