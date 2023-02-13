require 'rails_helper'

RSpec.describe "electricity out of hours advice page", type: :system do
  let(:key) { 'electricity_out_of_hours' }
  let(:expected_page_title) { "Out of school hours electricity use" }
  include_context "electricity advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:usage_breakdown) { nil }

      sign_in(user)
      visit school_advice_electricity_out_of_hours_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"
    end
    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }
      it_behaves_like "an advice page tab", tab: "Analysis"
    end
    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
