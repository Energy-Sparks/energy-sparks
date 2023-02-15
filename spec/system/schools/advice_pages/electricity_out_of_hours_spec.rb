require 'rails_helper'

RSpec.describe "electricity out of hours advice page", type: :system do
  let(:key) { 'electricity_out_of_hours' }
  let(:expected_page_title) { "Out of school hours electricity use" }
  include_context "electricity advice page"

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
          fuel_type: :electricity
        )
      end
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:total) { combined_usage_metric }
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:potential_savings) { combined_usage_metric }

      sign_in(user)
      visit school_advice_electricity_out_of_hours_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"

      it 'shows expected content' do
        expect(page).to have_content('What is out of hours usage?')
        expect(page).to have_content('Your out of hours usage')
        expect(page).to have_content('How do you compare?')
        expect(page).to have_content('What should you do next?')
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }
      it_behaves_like "an advice page tab", tab: "Analysis"

      it 'shows expected content' do
        expect(page).to have_content('Last 12 months')
        expect(page).to have_content('Usage by day of week')
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
