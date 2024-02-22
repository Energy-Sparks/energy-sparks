# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_peak_kw_per_pupil' do
  let(:school) { create(:school) }

  before do
    create(:advice_page, key: :electricity_intraday)

    alert_run = create(:alert_generation_run, school: school)

    baseload_alert = create(:alert_type, class_name: 'AlertElectricityPeakKWVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: baseload_alert,
                   variables: {
                     average_school_day_last_year_kw_per_floor_area: 1,
                     average_school_day_last_year_kw: 2,
                     exemplar_kw: 3,
                     saving_if_match_exemplar_gbp: 4
                   })

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end

  context 'when viewing report' do
    before { visit comparisons_electricity_peak_kw_per_pupil_index_path }

    it_behaves_like 'a school comparison report' do
      let(:title) { I18n.t('analytics.benchmarking.chart_table_config.electricity_peak_kw_per_pupil') }
      let(:chart) { '#chart_electricity_peak_kw_per_pupil' }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_electricity_intraday_path(expected_school) }
    end

    it 'displays the expected data' do
      expect(page).to have_css('#comparison-table tr', count: 3)
      expect(all('#comparison-table tr')[..-1].map { |tr| tr.all('th,td').map(&:text) }).to eq(
        [['School', 'Watt/floor area', 'Average peak kw', 'Exemplar peak kw',
          'Saving if match exemplar (£ at latest tariff)'],
         ['test 2 school [t]', '1,000', '2', '3', '£4']]
      )
    end
  end
end
