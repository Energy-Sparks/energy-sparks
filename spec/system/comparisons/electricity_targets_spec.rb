# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_targets' do
  let(:school) { create(:school) }

  before do
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertElectricityUsageDuringCurrentHoliday'),
                   variables: {
                     holiday_projected_usage_gbp: 1,
                     holiday_usage_to_date_gbp: 2,
                     holiday_name: 'Holiday 1'
                   })
  end

  context 'when viewing report' do
    before { visit comparisons_electricity_targets_index_path }

    it_behaves_like 'a school comparison report', advice_page: true do
      let(:title) { I18n.t('analytics.benchmarking.chart_table_config.electricity_targets') }
      let(:expected_school) { school }
    end
  end
end
