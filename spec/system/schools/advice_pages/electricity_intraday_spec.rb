require 'rails_helper'

RSpec.describe 'electricity intraday advice page', type: :system do
  let(:key) { 'electricity_intraday' }
  let(:expected_page_title) { 'Electricity intraday usage analysis' }

  include_context 'electricity advice page'

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    before do
      sign_in(user)
      allow_any_instance_of(Usage::PeakUsageBenchmarkingService).to receive(:average_peak_usage_kw).and_return(9_999_999.0)
      allow_any_instance_of(Usage::PeakUsageCalculationService).to receive(:average_peak_kw).and_return(9_999_999.0)

      visit school_advice_electricity_intraday_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab" do
      before do
        click_on 'Insights'
      end

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows all expected content' do
        expect(page).to have_content('Your current peak electricity use')
        expect(page).not_to have_content('Data on peak kw usage available from')
        expect(page).to have_content('How did we calculate these figures?')
        expect(page).to have_content('How do you compare?')
        expect(page).to have_content('How does your peak electricity use compare to other primary schools on Energy Sparks with a similar number of pupils')
        expect(page).to have_content('For more detail, compare with other schools in your group')
        expect(page).to have_content('10,000,000')
      end

      context 'when not enough data' do
        let(:start_date) { end_date - 11.months }

        it 'shows only relevent content' do
          expect(page).to have_content('Your current peak electricity use')
          expect(page).to have_content('Data on peak kw usage available from')
          expect(page).not_to have_content('How did we calculate these figures?')
          expect(page).not_to have_content('How do you compare?')
          expect(page).not_to have_content('How does your peak electricity use compare to other primary schools on Energy Sparks with a similar number of pupils')
          expect(page).not_to have_content('For more detail, compare with other schools in your group')
          expect(page).not_to have_content('10,000,000')
        end
      end
    end

    context "clicking the 'Analysis' tab" do
      before do
        click_on 'Analysis'
      end

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'shows titles' do
        expect(page).to have_content(I18n.t('advice_pages.electricity_intraday.analysis.comparison.title'))
      end

      it 'shows all of the expected charts' do
        expect(page).to have_css('#chart_wrapper_intraday_line_school_days_reduced_data_versus_benchmarks')
        expect(page).to have_css('#chart_wrapper_intraday_line_school_days_reduced_data')
        expect(page).to have_css('#chart_wrapper_intraday_line_holidays')
        expect(page).to have_css('#chart_wrapper_intraday_line_weekends')
        expect(page).to have_css('#chart_wrapper_intraday_line_school_last7days')
      end

      context 'when not enough data' do
        let(:start_date) { end_date - 11.months }

        it 'shows all of the expected charts' do
          expect(page).to have_css('#chart_wrapper_intraday_line_school_days_reduced_data_versus_benchmarks')
          expect(page).to have_css('#chart_wrapper_intraday_line_school_days_reduced_data')
          expect(page).to have_css('#chart_wrapper_intraday_line_holidays')
          expect(page).to have_css('#chart_wrapper_intraday_line_weekends')
          expect(page).to have_css('#chart_wrapper_intraday_line_school_last7days')
        end
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
