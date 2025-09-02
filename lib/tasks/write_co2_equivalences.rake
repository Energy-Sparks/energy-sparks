# frozen_string_literal: true

# This script is run annually, typically around September to regenerate data for
# app/models/schools/average_school_data.yaml.

task write_co2_equivalences: :environment do
  equivalence = SecrCo2Equivalence.order(:year).last
  File.write('analytics/lib/dashboard/equivalences/energy_equivalences_conversions.yaml',
             { electricity_co2e_co2: equivalence.electricity_co2e_co2,
               natural_gas_co2e_co2: equivalence.natural_gas_co2e_co2,
               year: equivalence.year }.to_yaml)
end
