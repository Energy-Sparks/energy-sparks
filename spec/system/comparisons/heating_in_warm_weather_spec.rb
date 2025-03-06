# frozen_string_literal: true

require 'rails_helper'

describe 'heating_in_warm_weather' do
  let!(:school) { create(:school) }
  let(:key) { :heating_in_warm_weather }
  let(:advice_page_key) { :heating_control }

  let(:gas_variables) do
    {
      percent_of_annual_heating: 0.11390515585484336,
      warm_weather_heating_days_all_days_kwh: 4648.785189592818,
      warm_weather_heating_days_all_days_co2: 976.2448898144918,
      warm_weather_heating_days_all_days_gbpcurrent: 139.46355568778452,
      warm_weather_heating_days_all_days_days: 150.0
    }
  end

  let(:storage_heater_variables) do
    {
      percent_of_annual_heating: 0.09318110030934608,
      warm_weather_heating_days_all_days_kwh: 7978.12,
      warm_weather_heating_days_all_days_co2: 1211.0252399999997,
      warm_weather_heating_days_all_days_gbpcurrent: 111.5115,
      warm_weather_heating_days_all_days_days: 18.0
    }
  end

  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertSeasonalHeatingSchoolDays'),
                   variables: gas_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertSeasonalHeatingSchoolDaysStorageHeaters'),
                   variables: storage_heater_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'))
  end

  before do
    create(:advice_page, key: advice_page_key)
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
        ['School',
         'Percentage of annual heating consumed in warm weather',
         'Saving through turning heating off in warm weather (kWh)',
         'Saving CO2 kg',
         'Saving £',
         'Number of days heating on in warm weather']
      end

      let(:expected_table) do
        [headers, [school.name, '11.4&percnt;', '4,650', '976', '£139', '150 days']]
      end

      let(:expected_csv) do
        [headers, [school.name, '11.4', '4,650', '976', '139', '150']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
