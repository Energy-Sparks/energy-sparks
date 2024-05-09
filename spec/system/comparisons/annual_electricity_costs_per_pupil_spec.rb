# frozen_string_literal: true

require 'rails_helper'

describe 'annual_electricity_costs_per_pupil' do
  let!(:school) { create(:school) }
  let(:key) { :annual_electricity_costs_per_pupil }
  let(:advice_page_key) { :electricity_long_term }

  let(:variables) do
    {
      one_year_electricity_per_pupil_gbp: 195.43244945007083,
      last_year_gbp: 234_518.939340085,
      one_year_saving_versus_exemplar_gbpcurrent: 154_778.21934008508
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertElectricityAnnualVersusBenchmark') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
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
         'Last year electricity £/pupil',
         'Last year electricity £',
         'Saving if matched exemplar school (using latest tariff)']
      end

      let(:expected_table) do
        [headers,
         [school.name,
          '£195',
          '£235,000',
          '£155,000'],
         ["Notes\nIn school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [headers,
         [school.name,
          '195',
          '235,000',
          '155,000']]
      end
    end
  end
end
