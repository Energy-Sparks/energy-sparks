require 'rails_helper'

RSpec.describe "gas out of hours advice page", type: :system do

  let(:key) { 'gas_out_of_hours' }
  let(:expected_page_title) { "Gas out of hours usage analysis" }
  include_context "gas advice page"

  context 'as school admin' do

    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_gas_out_of_hours_path(school)
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
