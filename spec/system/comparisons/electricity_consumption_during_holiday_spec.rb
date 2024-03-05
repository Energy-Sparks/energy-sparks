# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_consumption_during_holiday' do
  let(:school) { create(:school) }
  let!(:report) { create(:report, key: :electricity_consumption_during_holiday) }

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

    it_behaves_like 'a school comparison report' do
      let(:title) { report.title }
      let(:expected_school) { school }
      let(:expected_table) do
        [['School', 'Projected usage by end of holiday', 'Holiday usage to date', 'Holiday'],
         [school.name, '£1', '£2', 'Holiday 1']]
      end
    end
  end
end
