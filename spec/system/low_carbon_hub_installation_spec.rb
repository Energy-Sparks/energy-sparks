require 'rails_helper'
require 'dashboard'

RSpec.describe "Low carbon hub management", :low_carbon_hub_installations, type: :system do
  include_context "low carbon hub data"

  let!(:school_admin) { create(:user, role: 'school_admin', school_id: school.id) }

  context 'as school admin' do
    before(:each) do
      sign_in(school_admin)
      visit root_path


      low_carbon_hub_api_instance = double("API")
      allow(LowCarbonHubMeterReadings).to receive(:new).and_return(low_carbon_hub_api_instance)

      expect(low_carbon_hub_api_instance).to receive(:full_installation_information).with(rbee_meter_id).and_return(information)
      expect(low_carbon_hub_api_instance).to receive(:first_meter_reading_date).with(rbee_meter_id).and_return(start_date)
      expect(low_carbon_hub_api_instance).to receive(:download).with(rbee_meter_id, school.urn, start_date, end_date).and_return(readings)
    end

    it 'I can add a low carbon hub installation' do
      click_on 'Manage Low carbon hub installations'
      expect(page).to have_content("There are no Low carbon hub installations at the moment for this school")
      click_on 'New Low carbon hub installation'

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
  end
end
