require 'rails_helper'

RSpec.describe "electricity long term advice page", type: :system do
  let(:key) { 'electricity_long_term' }
  let(:expected_page_title) { "Long term changes in electricity consumption" }
  include_context "electricity advice page"

  let(:enough_data)  { true }
  let(:annual_usage) { CombinedUsageMetric.new(kwh: 1000, £: 500, co2: 1500) }
  let(:annual_usage_vs_benchmark) { CombinedUsageMetric.new(kwh: 800, £: 400, co2: 1300) }
  let(:annual_usage_vs_exemplar) { CombinedUsageMetric.new(kwh: 500, £: 300, co2: 1000) }

  let(:savings_vs_benchmark) { CombinedUsageMetric.new(kwh: 200, £: 100, co2: 200) }
  let(:savings_vs_exemplar) { CombinedUsageMetric.new(kwh: 500, £: 200, co2: 500) }

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive_messages(
        enough_data?: enough_data,
        annual_usage: annual_usage
      )
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:annual_usage_vs_benchmark).with(compare: :benchmark_school).and_return(annual_usage_vs_benchmark)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:annual_usage_vs_benchmark).with(compare: :exemplar_school).and_return(annual_usage_vs_exemplar)

      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:estimated_savings).with(versus: :benchmark_school).and_return(annual_usage_vs_benchmark)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:estimated_savings).with(versus: :exemplar_school).and_return(annual_usage_vs_exemplar)

      sign_in(user)
      visit school_advice_electricity_long_term_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"
    end
    context "clicking the 'Analysis' tab" do
      before do
        click_on 'Analysis'
      end
      it_behaves_like "an advice page tab", tab: "Analysis"
      it 'includes expected sections' do
        expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.recent_trend.title'))
        expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.title'))
        expect(page).to_not have_content(I18n.t('advice_pages.electricity_long_term.analysis.meter_breakdown.title'))
      end
      it 'says usage is high' do
        expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.assessment.high.title'))
      end
      it 'includes expected charts' do
        expect(page).to have_css('#chart_wrapper_group_by_week_electricity')
        expect(page).to have_css('#chart_wrapper_group_by_week_electricity_versus_benchmark')
        expect(page).to have_css('#chart_wrapper_group_by_week_electricity_unlimited')

        #not enough data for these
        expect(page).to_not have_css('#chart_wrapper_electricity_by_month_year_0_1')
        expect(page).to_not have_css('#chart_wrapper_electricity_longterm_trend')

      end
    end
    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
