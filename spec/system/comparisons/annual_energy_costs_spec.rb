# frozen_string_literal: true

require 'rails_helper'

describe 'annual_energy_costs' do
  let!(:school) { create(:school) }
  let(:key) { :annual_energy_costs }

  let(:electricity_variables) { { last_year_gbp: 161_059.43999999994 } }
  let(:gas_variables) { { last_year_gbp: 3159.183706023337 } }
  let(:storage_heater_variables) { { last_year_gbp: 1242.1469999999988 } }

  let(:energy_variables) do
    {
      last_year_gbp: 12_558.301294241202,
      one_year_energy_per_pupil_gbp: 76.57500789171466,
      last_year_co2_tonnes: 22.49842220799999,
      last_year_kwh: 115_096.06680000003
    }
  end

  let(:additional_variables) do
    {
      school_type_name: 'Primary',
      pupils: 363,
      floor_area: 3081.0
    }
  end

  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertElectricityAnnualVersusBenchmark'),
                   variables: electricity_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertGasAnnualVersusBenchmark'),
                   variables: gas_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertStorageHeaterAnnualVersusBenchmark'),
                   variables: storage_heater_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark'),
                   variables: energy_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: additional_variables)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { school_advice_path(school) }

      let(:headers) do
        ['School',
         'Last year electricity £',
         'Last year Gas £',
         'Last year Storage Heater £',
         'Total Energy Costs £',
         'Last year energy £/pupil',
         'Last year Energy CO2(tonnes)',
         'Last year Energy kWh',
         'Type',
         'Pupils',
         'Floor area']
      end

      let(:expected_table) do
        [headers,
         [school.name, '£161,000', '£3,160', '£1,240', '£12,600', '£76.60', '22.5', '115,000', 'Primary', '363',
          '3,080'],
         ["Notes\nThe gas, electricity and storage heater costs are all using the latest data. " \
          "The total might not be the sum of these 3 in the circumstance where one of the meter's data is out of date, " \
          "and the total then covers the most recent year where all data is available to us on all the underlying meters, and hence will cover the period of the most out of date of the underlying meters.\n" \
          "In school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '161,000', '3,160', '1,240', '12,600', '76.6', '22.5', '115,000', 'Primary', '363', '3,080']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
