require 'rails_helper'

RSpec.describe "gas costs advice page", type: :system do

  let(:key) { 'gas_costs' }
  let(:expected_page_title) { "Gas cost analysis" }
  include_context "a gas advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_gas_costs_path(school)
      save_and_open_page
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "visiting 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"
    end
    context "visiting 'Analysis' tab" do
      before { click_on 'Analysis' }
      it_behaves_like "an advice page tab", tab: "Analysis"
    end
    context "visiting 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
