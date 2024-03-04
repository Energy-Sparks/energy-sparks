# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_peak_kw_per_pupil' do
  let(:school) { create(:school) }
  let!(:report) { create(:report, key: :electricity_peak_kw_per_pupil) }

  before do
    create(:advice_page, key: :electricity_intraday)
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertElectricityPeakKWVersusBenchmark'),
                   variables: {
                     average_school_day_last_year_kw_per_floor_area: 1,
                     average_school_day_last_year_kw: 2,
                     exemplar_kw: 3,
                     one_year_saving_versus_exemplar_gbp: 4
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end

  context 'when viewing report' do
    before { visit comparisons_electricity_peak_kw_per_pupil_index_path }

    it_behaves_like 'a school comparison report' do
      let(:title) { report.title }
      let(:expected_school) { school }
      let(:chart) { true }
      let(:advice_page_path) { insights_school_advice_electricity_intraday_path(expected_school) }
      let(:expected_table) do
        [['School', 'W/floor area', 'Average peak kw', 'Exemplar peak kw',
          'Saving if match exemplar (£ at latest tariff)'],
         ["#{school.name} (*5)", '1,000', '2', '3', '£4'],
         ["Notes\n" \
          '(*5) The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          'tariff but other £ values are calculated using the relevant tariff at the time']]
      end
    end
  end
end
