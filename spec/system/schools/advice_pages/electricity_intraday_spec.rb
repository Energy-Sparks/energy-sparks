require 'rails_helper'

RSpec.describe "electricity intraday advice page", type: :system do
  let(:key) { 'electricity_intraday' }
  let(:expected_page_title) { "Electricity intraday usage analysis" }
  include_context "electricity advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_electricity_intraday_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"
    end

    context "clicking the 'Analysis' tab" do
      let(:start_date)          { Date.parse('20190101')}
      let(:end_date)            { Date.parse('20210101')}
      let(:amr_data)            { double('amr-data', start_date: start_date, end_date: end_date) }
      let(:aggregate_meter)     { double('aggregate_meter', amr_data: amr_data) }
      let(:aggregate_school)    { double('meter-collection') }

      before do
        allow(aggregate_school).to receive(:aggregated_electricity_meters).and_return(aggregate_meter)
        allow(aggregate_school).to receive(:aggregate_meter).and_return(aggregate_meter)
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregate_school)
        click_on 'Analysis'
      end

      it_behaves_like "an advice page tab", tab: "Analysis"

      it "shows titles" do
        expect(page).to have_content("Electricity consumption during the school day over the last 12 months")
      end

      it "shows dates for 7 day period up to end date" do
        expect(page).to have_content("graph shows how the electricity consumption for your school varies during the day between 26 Dec 2020 and 01 Jan 2021")
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
