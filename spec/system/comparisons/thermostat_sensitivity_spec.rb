# frozen_string_literal: true

require 'rails_helper'

describe 'thermostat_sensitivity' do
  let!(:school) { create(:school) }
  let(:key) { :thermostat_sensitivity }
  let(:advice_page_key) { :heating_control }

  let(:variables) do
    { annual_saving_1_C_change_gbp: 389.6826792646185 }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertHeatingSensitivityAdvice') }
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
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        ['School', 'Saving per 1C reduction in thermostat']
      end

      let(:expected_table) do
        [headers, [school.name, '£390']]
      end

      let(:expected_csv) do
        [headers, [school.name, '390']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
