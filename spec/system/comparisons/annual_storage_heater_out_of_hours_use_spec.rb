# frozen_string_literal: true

require 'rails_helper'

describe 'annual_storage_heater_out_of_hours_use' do
  let!(:school) { create(:school) }
  let(:key) { :annual_storage_heater_out_of_hours_use }
  let(:advice_page_key) { :storage_heaters }

  let(:variables) do
    {
      schoolday_open_percent: 0.2783819813845588,
      schoolday_closed_percent: 0.3712268903038169,
      holidays_percent: 0.21123782178479827,
      weekends_percent: 0.13915330652682595,
      holidays_gbp: 201,
      weekends_gbp: 216
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertStorageHeaterOutOfHours') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
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
         'Overnight charging',
         'Holiday',
         'Weekend',
         'Last year weekend and holiday costs']
      end

      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:expected_table) do
        [headers,
         [school.name, '27.8&percnt;', '37.1&percnt;', '21.1&percnt;', '13.9&percnt;', '£417'],
         ["Notes\n" \
          "In school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '27.8', '37.1', '21.1', '13.9', '417']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
