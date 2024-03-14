require 'rails_helper'

describe 'electricity_targets' do
  let!(:school) { create(:school) }
  let(:key) { :electricity_targets }
  let(:advice_page_key) { :electricity_long_term }

  let(:variables) do
    {
      current_year_percent_of_target_relative: +0.18699995372972533,
      current_year_unscaled_percent_of_target_relative: -0.4799985149375391,
      current_year_kwh: 1284.7,
      current_year_target_kwh: 2281.8825833333326,
      unscaled_target_kwh_to_date: 2401.9816666666666,
      tracking_start_date: '2024-01-01'
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertElectricityTargetAnnual') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  before do
    create(:advice_page, key: advice_page_key)
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
  end

  context 'when viewing report' do
    before { visit "/comparisons/#{key}" }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:headers) do
        ['School',
         'Percent above or below target since target set',
         'Percent above or below last year',
         'kWh consumption since target set',
         'Target kWh consumption',
         'Last year kWh consumption',
         'Start date for target']
      end
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      let(:expected_table) do
        [headers,
         [school.name,
          '+18.7&percnt;',
          '-48&percnt;',
          '1,280',
          '2,280',
          '2,400',
          'Monday 1 Jan 2024'],
         ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
]
      end
      let(:expected_csv) do
        [headers,
         [school.name,
          '18.7',
          '-48',
          '1,280',
          '2,280',
          '2,400',
          '2024-01-01']
        ]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:chart) { '#chart_comparison' }
    end
  end
end
