namespace :after_party do
  desc 'Deployment task: secr_co2_equivalences2025'
  task secr_co2_equivalences2025: :environment do
    puts "Running deploy task 'secr_co2_equivalences2025'"

    SecrCo2Equivalence.create!(year: 2025,
                               electricity_co2e: 0.17700,
                               electricity_co2e_co2: 0.17489,
                               transmission_distribution_co2e: 0.01853,
                               natural_gas_co2e: 0.18296,
                               natural_gas_co2e_co2: 0.18259)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
