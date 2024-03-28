require 'rails_helper'

describe 'annual_energy_costs_per_floor_area' do
  let!(:school) { create(:school) }
  let(:key) { :annual_energy_costs_per_floor_area }
  let(:advice_page_key) { :total_energy_use }

  let(:electricity_variables) do
    {
      one_year_electricity_per_floor_area_kwh: 100,
      one_year_electricity_per_floor_area_gbp: 110,
      one_year_electricity_per_floor_area_co2: 120
    }
  end

  let(:gas_variables) do
    {
      one_year_gas_per_floor_area_kwh: 200,
      one_year_gas_per_floor_area_gbp: 210,
      one_year_gas_per_floor_area_co2: 220
    }
  end

  let(:storage_heater_variables) do
    {
      one_year_gas_per_floor_area_kwh: 300,
      one_year_gas_per_floor_area_gbp: 310,
      one_year_gas_per_floor_area_co2: 320
    }
  end

  let(:additional_data_variables) do
    {
      electricity_economic_tariff_changed_this_year: true,
      gas_economic_tariff_changed_this_year: false,
      floor_area: 700
    }
  end


  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)

    electricity_alert = create(:alert_type, class_name: 'AlertElectricityAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: electricity_alert,
                   variables: electricity_variables)

    gas_alert = create(:alert_type, class_name: 'AlertGasAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: gas_alert,
                   variables: gas_variables)


    storage_heater_alert = create(:alert_type, class_name: 'AlertStorageHeaterAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: storage_heater_alert,
                   variables: storage_heater_variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: additional_data_variables)
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
          I18n.t('analytics.benchmarking.configuration.column_headings.type'),
          I18n.t('comparisons.column_headings.last_year_electricity_kwh_floor_area'),
          I18n.t('comparisons.column_headings.last_year_gas_kwh_floor_area'),
          I18n.t('comparisons.column_headings.last_year_storage_heater_kwh_floor_area'),
          I18n.t('comparisons.column_headings.last_year_energy_kwh_floor_area'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year_energy_£_floor_area'),
          I18n.t('comparisons.column_headings.last_year_energy_kgco2_floor_area'),
          I18n.t('analytics.benchmarking.configuration.column_headings.floor_area')
        ]
      end
      let(:expected_table) do
        [
          headers,
          ["#{school.name} [5]",
           I18n.t('common.school_types.' + school.school_type),
           '100',
           '200',
           '300',
           '600',
           '£630',
           '660',
           '700'],
          ["Notes\n" \
           '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
           "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
           "'last year' is defined as this year to date."]
        ]
      end
      let(:expected_csv) do
        [
          headers,
          [school.name,
           I18n.t('common.school_types.' + school.school_type),
           '100',
           '200',
           '300',
           '600',
           '630',
           '660',
           '700']
        ]
      end
    end
  end
end
