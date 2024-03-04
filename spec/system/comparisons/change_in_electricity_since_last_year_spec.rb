require 'rails_helper'

describe 'change_in_electricity_since_last_year', type: :system do
  let(:variables) do
    {
      previous_year_electricity_kwh: 1000.0,
      current_year_electricity_kwh: 500.0,
      previous_year_electricity_co2: 800.0,
      current_year_electricity_co2: 400.0,
      previous_year_electricity_gbp: 2000.0,
      current_year_electricity_gbp: 1200.0,
      solar_type: 'synthetic'
    }
  end

  let!(:school) { create(:school) }
  let!(:report) { create(:report, key: :change_in_electricity_since_last_year)}

  before do
    create(:advice_page, key: :electricity_long_term)

    alert_run = create(:alert_generation_run, school: school)

    alert = create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert, variables: variables)
  end

  context 'when viewing report' do
    before do
      visit comparisons_change_in_electricity_since_last_year_index_path
    end

    it_behaves_like 'a school comparison report' do
      let(:title) { report.title }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_electricity_long_term_path(expected_school) }
    end

    it 'displays the expected data' do
      within('#tables') do
        within('#comparison-table') do
          expect(page).to have_content('1,000') # previous_year_electricity_kwh per pupil
          expect(page).to have_content('500') # current_year_electricity_kwh

          expect(page).to have_content('800') # previous_year_electricity_co2
          expect(page).to have_content('400') # current_year_electricity_co2

          expect(page).to have_content('£2,000') # previous_year_electricity_gbp
          expect(page).to have_content('£1,200') # previous_year_electricity_gbp

          expect(page).to have_content('Yes') # solar
        end
      end
    end
  end
end
