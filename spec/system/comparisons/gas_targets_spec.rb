require 'rails_helper'

describe 'gas_targets' do
  let!(:school) { create(:school) }
  let(:key) { :gas_targets }
  let(:advice_page_key) { :your_advice_page_key }

  let(:variables) do
    {
      current_year_percent_of_target_relative: 0.04776034499367143,
      current_year_unscaled_percent_of_target_relative: -0.0046276722560122385,
      current_year_kwh: 28032.135000000002,
      current_year_target_kwh: 26754.33856028338,
      unscaled_target_kwh_to_date: 28162.461642403563,
      tracking_start_date: '2024-03-01'
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertGasTargetAnnual') }
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
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        ['School',
         'Percent above or below target since target set',
         'Percent above or below last year',
         'kWh consumption since target set',
         'Target kWh consumption',
         'Last year kWh consumption',
         'Start date for target']
      end

      let(:expected_table) do
        [headers,
         [school.name, '+4.78%', '-0.463%', '28,000', '26,800', '28,200', 'Friday 1 Mar 2024'],
         ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '4.78', '-0.463', '28,000', '26,800', '28,200', 'Friday  1 Mar 2024']
        ]
      end
    end

    it_behaves_like 'a school comparison report with a chart'
  end
end
