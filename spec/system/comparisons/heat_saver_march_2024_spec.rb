require 'rails_helper'

describe 'heat_saver_march_2024' do
  let!(:school) { create(:school) }
  let(:key) { :heat_saver_march_2024 }
  let(:advice_page_key) { :total_energy_use }

  # change to your variables
  let(:usage_variables) do
    {
      current_period_kwh: 1000.0,
      previous_period_kwh: 2000.0,
      current_period_co2: 100.0,
      previous_period_co2: 200.0,
      current_period_gbp: 2000.0,
      previous_period_gbp: 4000.0,
      tariff_has_changed: true,
      pupils_changed: true,
      floor_area_changed: true
    }
  end

  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [electricity_change_rows, gas_change_rows, tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)
    alert_run = create(:alert_generation_run, school: school)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { activation_date: Time.zone.today })

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark'),
                   variables: { solar_type: 'metered' })

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatSaver2024ElectricityComparison'),
                   variables: usage_variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatSaver2024GasComparison'),
                   variables: usage_variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatSaver2024StorageHeaterComparison'),
                   variables: usage_variables)
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
