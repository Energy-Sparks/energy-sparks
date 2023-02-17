require 'rails_helper'

RSpec.describe "total energy use advice page", type: :system do
  let(:key) { 'total_energy_use' }
  let(:expected_page_title) { "Total energy use" }
  include_context "electricity advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }
    let(:gas_aggregate_meter)   { double('gas-aggregated-meter')}

    let(:management_data) {
      Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 } } })
    }

    let(:enough_data)  { true }
    let(:annual_usage) { CombinedUsageMetric.new(kwh: 1000, £: 500, co2: 1500) }
    let(:annual_usage_vs_benchmark) { CombinedUsageMetric.new(kwh: 800, £: 400, co2: 1300) }
    let(:annual_usage_vs_exemplar) { CombinedUsageMetric.new(kwh: 500, £: 300, co2: 1000) }

    let(:annual_usage) { CombinedUsageMetric.new(kwh: 1000, £: 500, co2: 1500) }
    let(:annual_usage_vs_benchmark) { CombinedUsageMetric.new(kwh: 800, £: 400, co2: 1300) }
    let(:annual_usage_vs_exemplar) { CombinedUsageMetric.new(kwh: 500, £: 300, co2: 1000) }

    let(:savings_vs_benchmark) { CombinedUsageMetric.new(kwh: 200, £: 100, co2: 200) }
    let(:savings_vs_exemplar) { CombinedUsageMetric.new(kwh: 500, £: 200, co2: 500) }


    before do
      allow(gas_aggregate_meter).to receive(:amr_data).and_return(amr_data)
      allow(meter_collection).to receive(:aggregated_heat_meters).and_return(gas_aggregate_meter)

      allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive_messages(
        enough_data?: enough_data,
        annual_usage: annual_usage
      )
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:annual_usage_kwh).with(compare: :benchmark_school).and_return(annual_usage_vs_benchmark.kwh)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:annual_usage_kwh).with(compare: :exemplar_school).and_return(annual_usage_vs_exemplar.kwh)

      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:annual_usage_vs_benchmark).with(compare: :benchmark_school).and_return(annual_usage_vs_benchmark)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:annual_usage_vs_benchmark).with(compare: :exemplar_school).and_return(annual_usage_vs_exemplar)

      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:estimated_savings).with(versus: :benchmark_school).and_return(annual_usage_vs_benchmark)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:estimated_savings).with(versus: :exemplar_school).and_return(annual_usage_vs_exemplar)

      sign_in(user)
      visit school_advice_total_energy_use_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"

      it 'has expected content' do
        expect(page).to have_content(I18n.t('advice_pages.total_energy_use.insights.intro.text'))
        expect(page).to have_css('#management-overview-table')
        expect(page).to have_content("How does your energy use for the last 12 months compare to other primary schools")
      end
    end
    context "clicking the 'Analysis' tab" do
      context 'with default data' do
        before { click_on 'Analysis' }
        it_behaves_like "an advice page tab", tab: "Analysis"
        it 'has expected content' do
          expect(page).to have_content(I18n.t('advice_pages.total_energy_use.analysis.comparison.title'))
          #only one year of data in mocked out data
          expect(page).to_not have_css('#long-term-trend')
        end
        it 'has expected charts' do
          expect(page).to have_css('#chart_wrapper_benchmark_one_year')
          #only one year of data in mocked out data
          expect(page).to_not have_css('#chart_wrapper_stacked_all_years')
        end
      end
      context 'with more data' do
        before { click_on 'Analysis' }
        let(:start_date) { end_date - 2.years}
        it 'has expected content' do
          expect(page).to have_content(I18n.t('advice_pages.total_energy_use.analysis.comparison.title'))
          expect(page).to have_css('#long-term-trend')
        end
        it 'has expected charts' do
          expect(page).to have_css('#chart_wrapper_benchmark_one_year')
          expect(page).to have_css('#chart_wrapper_stacked_all_years')
        end
      end
    end
    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
