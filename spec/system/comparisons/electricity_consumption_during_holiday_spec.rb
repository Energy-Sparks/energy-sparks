# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_consumption_during_holiday' do
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
    before { visit comparisons_electricity_consumption_during_holiday_index_path }

    it_behaves_like 'a school comparison report', advice_page: false do
      let(:title) { I18n.t('analytics.benchmarking.chart_table_config.electricity_consumption_during_holiday') }
      let(:expected_school) { school }
    end

    it 'displays the expected data' do
      expect(page).to have_css('#comparison-table tr', count: 2)
      expect(all('#comparison-table tr').map { |tr| tr.all('th,td').map(&:text) }).to eq(
        [['School', 'Projected usage by end of holiday', 'Holiday usage to date', 'Holiday'],
         [school.name, '£1', '£2', 'Holiday 1']]
      )
    end
  end
end
