require 'rails_helper'

describe 'change_in_energy_since_last_year' do
  let!(:school) { create(:school) }
  let(:key) { :change_in_energy_since_last_year }
  let(:advice_page_key) { :total_energy_use }

  let(:variables) do
    {
      previous_year_electricity_kwh: 0,
      current_year_electricity_kwh: 0,
      previous_year_electricity_co2: 0,
      current_year_electricity_co2: 0,
      previous_year_electricity_gbp: 0,
      current_year_electricity_gbp: 0,

      previous_year_gas_kwh: 0,
      current_year_gas_kwh: 0,
      previous_year_gas_co2: 0,
      current_year_gas_co2: 0,
      previous_year_gas_gbp: 0,
      current_year_gas_gbp: 0,

      previous_year_storage_heaters_kwh: 0,
      current_year_storage_heaters_kwh: 0,
      previous_year_storage_heaters_co2: 0,
      current_year_storage_heaters_co2: 0,
      previous_year_storage_heaters_gbp: 0,
      current_year_storage_heaters_gbp: 0,

      previous_year_solar_pv_kwh: 0,
      current_year_solar_pv_kwh: 0,
      previous_year_solar_pv_co2: 0,
      current_year_solar_pv_co2: 0,
      previous_year_solar_pv_gbp: 0,
      current_year_solar_pv_gbp: 0,

      solar_type: 'synthetic'
    }
  end

  let!(:report) { create(:report, key: key) }

  before do
    create(:advice_page, key: advice_page_key)

    alert_run = create(:alert_generation_run, school: school)

    alert = create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert, variables: variables)
  end

  context 'when viewing report' do
    before { visit "/comparisons/#{key}" }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.fuel'),
          I18n.t('analytics.benchmarking.configuration.column_headings.no_recent_data')
        ]
      end

      let(:expected_table) do
        [['', 'kWh', 'CO2 (kg)', 'Cost', 'Metering'],
         headers,
         [school.name,
          '£195',
          '£235,000',
          '£155,000',
         ],
         ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end

      let(:expected_csv) do
        [['', 'kWh', '', '', 'CO2 (kg)', '', '', 'Cost', '', '', 'Metering', '', ''],
         headers,
         [school.name,
          '195',
          '235,000',
          '155,000']
        ]
      end
    end
  end
end
