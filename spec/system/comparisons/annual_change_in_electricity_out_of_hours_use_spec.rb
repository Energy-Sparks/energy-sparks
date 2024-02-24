# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_peak_kw_per_pupil' do
  let(:school) { create(:school) }

  before do
    create(:advice_page, key: :electricity_out_of_hours)
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertOutOfHoursElectricityUsage'),
                   variables: {
                     out_of_hours_kwh: 1,
                     out_of_hours_co2: 2,
                     out_of_hours_gbpcurrent: 3
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertOutOfHoursElectricityUsagePreviousYear'),
                   variables: {
                     out_of_hours_kwh: 4,
                     out_of_hours_co2: 5,
                     out_of_hours_gbpcurrent: 6
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end

  context 'when viewing report' do
    before { visit comparisons_annual_change_in_electricity_out_of_hours_use_index_path }

    it_behaves_like 'a school comparison report' do
      let(:title) { I18n.t('analytics.benchmarking.chart_table_config.annual_change_in_electricity_out_of_hours_use') }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_electricity_out_of_hours_path(expected_school) }
    end

    it 'displays the expected data' do
      expect(page).to have_css('#comparison-table tr', count: 3)
      expect(all('#comparison-table tr')[..-2].map { |tr| tr.all('th,td').map(&:text) }).to eq(
        [['School', 'Watt/floor area', 'Average peak kw', 'Exemplar peak kw',
          'Saving if match exemplar (£ at latest tariff)'],
         ["#{school.name} [t]", '1,000', '2', '3', '£4']]
      )
    end
  end
end
