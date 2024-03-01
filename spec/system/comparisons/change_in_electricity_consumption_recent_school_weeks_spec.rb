# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_peak_kw_per_pupil' do
  let(:school) { create(:school) }

  before do
    create(:alert, school: school,
                   alert_generation_run: create(:alert_generation_run, school: school),
                   alert_type: create(:alert_type, class_name: 'AlertSchoolWeekComparisonElectricity'),
                   variables: {
                     difference_percent: 1,
                     difference_gbpcurrent: 2,
                     difference_kwh: 3,
                     pupils_changed: true,
                     tariff_has_changed: true
                   })
  end

  context 'when viewing report' do
    before { visit comparisons_change_in_electricity_consumption_recent_school_weeks_path }

    it_behaves_like 'a school comparison report', advice_page: false do
      let(:title) do
        I18n.t('analytics.benchmarking.chart_table_config.change_in_electricity_consumption_recent_school_weeks')
      end
      let(:expected_school) { school }
      let(:expected_table) do
        [['School', 'Watt/floor area', 'Average peak kw', 'Exemplar peak kw',
          'Saving if match exemplar (£ at latest tariff)'],
         ["#{school.name} (*5)", '1,000', '2', '3', '£4']]
      end
    end
  end
end
