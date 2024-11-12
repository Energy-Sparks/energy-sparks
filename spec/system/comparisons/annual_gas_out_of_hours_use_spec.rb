# frozen_string_literal: true

require 'rails_helper'

describe 'annual_gas_out_of_hours_use' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { gas_economic_tariff_changed_this_year: true })
  end
  let(:key) { :annual_gas_out_of_hours_use }
  let(:advice_page_key) { :gas_out_of_hours }

  let(:variables) do
    {
      schoolday_open_percent: 0.2783819813845588,
      schoolday_closed_percent: 0.3712268903038169,
      holidays_percent: 0.21123782178479827,
      weekends_percent: 0.13915330652682595,
      community_percent: 0.0,
      community_gbp: 0.0,
      out_of_hours_gbp: 41_347.98790211005,
      potential_saving_gbp: 13_006.849331677073
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertOutOfHoursGasUsage') }
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
      let(:headers) do
        ['School',
         'School Day Open',
         'School Day Closed',
         'Holiday',
         'Weekend',
         'Community',
         'Community usage cost',
         'Last year out of hours cost',
         'Saving if improve to exemplar (at latest tariff)']
      end

      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:expected_table) do
        [headers,
         ["#{school.name} [5]", '27.8&percnt;', '37.1&percnt;', '21.1&percnt;', '13.9&percnt;', '0&percnt;', '0p',
          '£41,300', '£13,000'],
         ["Notes\n" \
          '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
          "'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '27.8', '37.1', '21.1', '13.9', '0', '0', '41,300', '13,000']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
