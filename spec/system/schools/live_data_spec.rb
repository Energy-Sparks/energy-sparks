require 'rails_helper'

RSpec.describe 'live data', type: :system do

  let!(:school)             { create(:school) }
  let!(:school_admin)       { create(:school_admin, school: school) }

  context 'with feature disabled' do

    before(:each) do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
      sign_in(school_admin)
      visit school_live_data_path(school)
    end

    it 'does not let me view live data' do
      expect(page).to have_content("Dashboard")
      expect(page).to_not have_content("live data")
    end
  end

  context 'with feature enabled and active cad' do

    let!(:cad) { create(:cad, active: true, school: school) }

    before(:each) do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      sign_in(school_admin)
      visit school_path(school)
      click_link 'Live energy data'
    end

    it 'lets me view live data' do
      expect(page).to have_content("Your live energy data")
      expect(page).to have_content("Understanding your data consumption")
    end

    it 'has help page' do
      create(:help_page, title: "Live data", feature: :live_data, published: true)
      refresh
      expect(page).to have_link("Help")
    end

    it 'has links to suggestions actions etc' do
      expect(page).to have_content("Working with the pupils")
      expect(page).to have_content("Taking action around the school")
      expect(page).to have_content("Explore your data")
      expect(page).to have_link("Choose another activity")
      expect(page).to have_link("Record an energy saving action")
      expect(page).to have_link("View dashboard")
    end

    it 'links from pupil analysis page' do
      visit pupils_school_analysis_path(school)
      within '.live-data-card' do
        expect(page).to have_content("Live energy data")
        click_link "Live energy data"
      end
      expect(page).to have_content("Your live energy data")
    end
  end
end
