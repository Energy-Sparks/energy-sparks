require 'rails_helper'

describe 'change_in_energy_since_last_year' do
  let!(:school) { create(:school) }
  let(:key) { :change_in_energy_since_last_year }
  let(:advice_page_key) { :your_advice_page_key }

  # change to your variables
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

  # change to your alert type (there may be more than one!)
  let(:alert_type) { create(:alert_type, class_name: 'AlertElectricityTargetAnnual') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  before do
    create(:advice_page, key: advice_page_key)
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
    # the following alert is often only required for the tariff changed footnote
    # delete or amend as appropriate:
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
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
          '£155,000',
         ],
         ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end

      let(:expected_csv) do
        [headers,
         [school.name,
          '195',
          '235,000',
          '155,000']
        ]
      end
    end

    it_behaves_like 'a school comparison report with a chart'
  end
end
