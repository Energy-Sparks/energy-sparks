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
      let(:title) { report.title }
      let(:chart) { '#chart_comparison' }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
    end

    it 'displays the expected data' do
      within('#tables') do
        within('#comparison-table') do
          expect(page).to have_content('+18.7%') # Percent above or below target since target set
          expect(page).to have_content('-48%') # Percent above or below last year
          expect(page).to have_content('1,280') # kWh consumption since target set
          expect(page).to have_content('2,280') # Target kWh consumption
          expect(page).to have_content('2,400') # Last year kWh consumption
          expect(page).to have_content('Monday 1 Jan 2024') # Start date for target
        end
      end
    end
  end
end
