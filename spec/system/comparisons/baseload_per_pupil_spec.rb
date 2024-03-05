require 'rails_helper'

describe 'baseload_per_pupil', type: :system do
  let(:baseload_variables) do
    {
      average_baseload_last_year_kw: 20.0,
      average_baseload_last_year_gbp: 1000.0,
      one_year_baseload_per_pupil_kw: 0.002,
      annual_baseload_percent: 0.1,
      one_year_saving_versus_exemplar_gbp: 200.0
    }
  end

  let(:additional_data_variables) do
    {
      electricity_economic_tariff_changed_this_year: true
    }
  end

  let!(:school) { create(:school) }
  let!(:report) { create(:report, key: :baseload_per_pupil)}

  before do
    create(:advice_page, key: :baseload)

    alert_run = create(:alert_generation_run, school: school)

    baseload_alert = create(:alert_type, class_name: 'AlertElectricityBaseloadVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: baseload_alert,
                   variables: baseload_variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: additional_data_variables)
  end

  context 'when viewing report' do
    before do
      visit comparisons_baseload_per_pupil_index_path
    end

    it_behaves_like 'a school comparison report' do
      let(:comparison_page_path) { comparisons_baseload_per_pupil_index_path }
      let(:expected_report) { report }
      let(:chart) { true }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_baseload_path(expected_school) }
      let(:expected_table) do
        [['School', 'Baseload per pupil (W)', 'Last year cost of baseload', 'Average baseload kW',
          'Baseload as a percent of total usage', 'Saving if matched exemplar school (using latest tariff)'],
         ["#{school.name} [t]", '2', '£1,000', '20', '10&percnt;', '£200'],
         ["Notes\n[t]\n" \
          '(*5) The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
          "'last year' is defined as this year to date."]]
      end
    end
  end
end
