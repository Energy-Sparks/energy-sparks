# frozen_string_literal: true

require 'rails_helper'

describe 'annual_heating_costs_per_floor_area' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertGasAnnualVersusBenchmark'),
                   variables: gas_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertStorageHeaterAnnualVersusBenchmark'),
                   variables: storage_heater_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { gas_economic_tariff_changed_this_year: true })
  end
  let(:key) { :annual_heating_costs_per_floor_area }
  let(:advice_page_key) { :gas_long_term }

  let(:gas_variables) do
    {
      one_year_gas_per_floor_area_normalised_gbp: 1.5648308614918232,
      last_year_gbp: 3159.183706023337,
      one_year_saving_versus_exemplar_gbpcurrent: -1686.0945160764745,
      last_year_kwh: 105_306.1235341111,
      last_year_co2: 22_114.285942163337
    }
  end

  let(:storage_heater_variables) do
    {
      one_year_gas_per_floor_area_normalised_gbp: 1.1464497686677348,
      last_year_gbp: 1242.1469999999988,
      one_year_saving_versus_exemplar_gbpcurrent: -11_759.525124999996,
      last_year_kwh: 8280.979999999996,
      last_year_co2: 1273.7466299999996
    }
  end

  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        ['School',
         'Last year heating costs per floor area',
         'Last year cost £',
         'Saving if matched exemplar school (using latest tariff)',
         'Last year consumption kWh',
         'Last year carbon emissions (tonnes CO2)']
      end

      let(:expected_table) do
        [headers,
         ["#{school.name} [5]", '£2.71', '£4,400', '-£13,400', '114,000', '23.4'],
         ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '2.71', '4,400', '-13,400', '114,000', '23.4']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
