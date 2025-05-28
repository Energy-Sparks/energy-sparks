# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: secr_co2_equivalences2024'
  task secr_co2_equivalences2024: :environment do
    puts "Running deploy task 'secr_co2_equivalences2024'"

    SecrCo2Equivalence.create!(year: 2024,
                               electricity_co2e: 0.20705,
                               electricity_co2e_co2: 0.20493,
                               transmission_distribution_co2e: 0.01830,
                               natural_gas_co2e: 0.18290,
                               natural_gas_co2e_co2: 0.18253)
    SecrCo2Equivalence.create!(year: 2023,
                               electricity_co2e: 0.207074,
                               electricity_co2e_co2: 0.20496,
                               transmission_distribution_co2e: 0.01830,
                               natural_gas_co2e: 0.18,
                               natural_gas_co2e_co2: 0.18256)
    SecrCo2Equivalence.create!(year: 2022,
                               electricity_co2e: 0.19338,
                               electricity_co2e_co2: 0.19121,
                               transmission_distribution_co2e: 0.01769,
                               natural_gas_co2e: 0.18,
                               natural_gas_co2e_co2: 0.18219)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
