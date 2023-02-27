require 'rails_helper'

RSpec.describe "gas out of hours advice page", type: :system do
  let(:key) { 'gas_out_of_hours' }
  let(:expected_page_title) { "Out of school hours gas use" }
  include_context "gas advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      combined_usage_metric = CombinedUsageMetric.new(
        £: 12.0,
        kwh: 12.0,
        co2: 12.0,
        percent: 0.4
      )

      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:usage_breakdown) do
        Usage::AnnualUsageCategoryBreakdown.new(
          holiday: combined_usage_metric,
          school_day_closed: combined_usage_metric,
          school_day_open: combined_usage_metric,
          weekend: combined_usage_metric,
          out_of_hours: combined_usage_metric,
          community: combined_usage_metric,
          fuel_type: :gas
        )
      end
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:total) { combined_usage_metric }
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:potential_savings) { combined_usage_metric }

      sign_in(user)
      visit school_advice_gas_out_of_hours_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"

      it 'shows expected content' do
        expect(page).to have_content('Out of school hours gas use')
        expect(page).to have_content('How do you compare?')
        expect(page).to have_content('What should you do next?')
        expect(page).to have_content('Exemplar')
        expect(page).to have_content('12')
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }
      it_behaves_like "an advice page tab", tab: "Analysis"

      it 'shows expected content' do
        expect(page).to have_content('Last 12 months')
        expect(page).to have_content('Usage by day of week')
        expect(page).to have_content('12')
        expect(page).to have_content('Holiday')
        expect(page).to have_css('#chart_wrapper_daytype_breakdown_gas_tolerant')
        expect(page).to have_css('#chart_wrapper_gas_by_day_of_week_tolerant')
        expect(page).to have_css('#chart_wrapper_gas_heating_season_intraday_up_to_1_year')
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
