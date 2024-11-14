# frozen_string_literal: true

require 'rails_helper'

describe 'baseload_per_pupil' do
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
  let!(:report) { create(:report, key: :baseload_per_pupil) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: school)

    baseload_alert = create(:alert_type, class_name: 'AlertElectricityBaseloadVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: baseload_alert,
                   variables: baseload_variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: additional_data_variables)
  end

  before do
    create(:advice_page, key: :baseload)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_baseload_path(expected_school) }
      let(:headers) do
        ['School', 'Baseload per pupil (W)', 'Last year cost of baseload', 'Average baseload kW',
         'Baseload as a percent of total usage', 'Saving if matched exemplar school (using latest tariff)']
      end
      let(:expected_table) do
        [headers,
         ["#{school.name} [5]", '2', '£1,000', '20', '10&percnt;', '£200'],
         ["Notes\n" \
          '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
          "'last year' is defined as this year to date."]]
      end
      let(:expected_csv) do
        [headers, [school.name, '2', '1,000', '20', '10', '200']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
