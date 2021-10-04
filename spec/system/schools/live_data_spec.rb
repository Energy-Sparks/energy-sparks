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

  context 'with feature enabled' do

    before(:each) do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      sign_in(school_admin)
      visit school_live_data_path(school)
    end

    it 'lets me view live data' do
      expect(page).to have_content("Your live energy data")
    end

    it 'has help page' do
      create(:help_page, title: "Live data", feature: :live_data, published: true)
      refresh
      expect(page).to have_link("Help")
    end
  end
end
