require 'rails_helper'

describe 'baseload_per_pupil', type: :system do
  let(:baseload_variables) do
    {
      average_baseload_last_year_kw: 20.0,
      average_baseload_last_year_gbp: 1000.0,
      one_year_baseload_per_pupil_kw: 0.002,
      annual_baseload_percent: 0.1,
      one_year_saving_versus_exemplar_gbp: 200.0
    }
  end

  let(:additional_data_variables) do
    {
      electricity_economic_tariff_changed_this_year: true
    }
  end

  let!(:school) { create(:school) }
  let!(:report) { create(:report, key: :baseload_per_pupil)}

  before do
    create(:advice_page, key: :baseload)

    alert_run = create(:alert_generation_run, school: school)

    baseload_alert = create(:alert_type, class_name: 'AlertElectricityBaseloadVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: baseload_alert,
      variables: baseload_variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
      variables: additional_data_variables)
  end

  context 'when viewing report' do
    before do
      visit comparisons_baseload_per_pupil_index_path
    end

    it_behaves_like 'a school comparison report' do
      let(:title) { report.title }
      let(:chart) { '#chart_baseload_per_pupil' }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_baseload_path(expected_school) }
    end

    it 'displays the expected data' do
      within('#tables') do
        within('#comparison-table') do
          expect(page).to have_content('2') # baseload per pupil
          expect(page).to have_content('£1,000') # cost
          expect(page).to have_content('20') # average
          expect(page).to have_content('10&percnt;') # %
          expect(page).to have_content('£200') # savings
        end
      end
    end
  end
end
