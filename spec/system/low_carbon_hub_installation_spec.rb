require 'rails_helper'
require 'dashboard'

RSpec.describe "Low carbon hub management", :low_carbon_hub_installations, type: :system do
  include_context "low carbon hub data"

  let!(:admin) { create(:admin) }

  context 'as an admin' do
    before(:each) do
      sign_in(admin)
      visit school_path(school)

      click_on 'Manage Low carbon hub installations'
      expect(page).to have_content("There are no Low carbon hub installations at the moment for this school")
      click_on 'New Low carbon hub installation'
    end

    it 'I can add a low carbon hub installation' do
      allow(LowCarbonHubMeterReadings).to receive(:new).and_return(low_carbon_hub_api)

      fill_in(:low_carbon_hub_installation_rbee_meter_id, with: rbee_meter_id)
      expect { click_on 'Create' }.to change { Meter.count }.by(3).and change { LowCarbonHubInstallation.count }.by(1).and change { AmrDataFeedReading.count }.by(6)

      expect(page).to_not have_content("There are no Low carbon hub installations at the moment for this school")
      expect(page).to have_content(rbee_meter_id)
      expect(school.low_carbon_hub_installations.count).to be 1
      expect(school.meters.count).to be 3

      expect(page).to have_content(info_text)
      click_on "All low carbon hub installations for #{school.name}"
      click_on 'Details'
      expect(page).to have_content(info_text)
      click_on "All low carbon hub installations for #{school.name}"
      expect(page).to have_content("Delete")
      expect { click_on 'Delete' }.to change { Meter.count }.by(-3).and change { LowCarbonHubInstallation.count }.by(-1)

      expect(page).to have_content("There are no Low carbon hub installations at the moment for this school")
    end

    it 'handles being run out of hours properly' do
      expect(LowCarbonHubMeterReadings).to receive(:new).and_raise(EnergySparksUnexpectedStateException)

      click_on 'Create'
      expect(page).to have_content("There are no Low carbon hub installations at the moment for this school")
      expect(page).to have_content("Low carbon hub API is not available at the moment")
    end

    it 'I delete a low carbon hub installation and meter readngs get removed' do

      expect { create(:low_carbon_hub_installation_with_meters_and_validated_readings, school: school) }.to change { Meter.count }.by(3).and change { AmrValidatedReading.count }.by(3)

      visit school_path(school)

      low_carbon_hub_installation = LowCarbonHubInstallation.first

      click_on 'Manage Low carbon hub installations'
      expect(page).to have_content low_carbon_hub_installation.rbee_meter_id
      expect { click_on 'Delete' }.to change { Meter.count }.by(-3).and change { LowCarbonHubInstallation.count }.by(-1).and change { AmrValidatedReading.count }.by(-3)



    end
  end
end
