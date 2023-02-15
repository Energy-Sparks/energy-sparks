require 'rails_helper'

RSpec.describe "solar pv advice page", type: :system do
  let(:key) { 'solar_pv' }
  include_context "solar advice page"

  def expected_page_title
    school.has_solar_pv? ? 'Solar PV generation' : 'Benefits of installing solar panels'
  end

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_solar_pv_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab as a school *without* solar pv" do

      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?) { false }

        click_on 'Insights'
      end

      it_behaves_like "an advice page tab", tab: "Insights"

      it 'shows expected content' do
        expect(page).to have_content('Benefits of installing solar panels')
        expect(page).not_to have_content('Solar PV generation')
      end
    end

    context "clicking the 'Insights' tab as a school *with* solar pv" do

      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?) { true }

        click_on 'Insights'
      end

      it_behaves_like "an advice page tab", tab: "Insights"

      it 'shows expected content' do
        expect(page).not_to have_content('Benefits of installing solar panels')
        expect(page).to have_content('Solar PV generation')
      end
    end

    context "clicking the 'Analysis' tab as a school *without* solar pv" do

      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?) { false }
        @expected_page_title = "Benefits of installing solar panels"

        click_on 'Analysis'
      end

      it_behaves_like "an advice page tab", tab: "Analysis"

      it 'shows expected content' do
        expect(page).to have_content('Analysis')
      end
    end

    context "clicking the 'Analysis' tab as a school *with* solar pv" do

      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?) { true }

        click_on 'Analysis'
      end

      it_behaves_like "an advice page tab", tab: "Analysis"

      it 'shows expected content' do
        expect(page).to have_content('Analysis')
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
