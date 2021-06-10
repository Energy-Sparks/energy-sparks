require 'rails_helper'
require 'dashboard'

RSpec.describe "Low carbon hub management", :low_carbon_hub_installations, type: :system do
  include_context "low carbon hub data"

  let!(:admin) { create(:admin) }

  context 'as an admin' do
    before(:each) do
      sign_in(admin)
      visit school_meters_path(school)
      click_on 'Manage Solar API feeds'
    end

    it 'I can add and delete a low carbon hub installation' do
      expect(page).to have_content("This school has no Rtone API feeds")
      click_on 'New Rtone installation'

      allow(LowCarbonHubMeterReadings).to receive(:new).and_return(low_carbon_hub_api)

      fill_in(:low_carbon_hub_installation_rbee_meter_id, with: rbee_meter_id)
      fill_in(:low_carbon_hub_installation_username, with: username)
      fill_in(:low_carbon_hub_installation_password, with: password)

      expect { click_on 'Submit' }.to change { Meter.count }.by(3).and change { LowCarbonHubInstallation.count }.by(1).and change { AmrDataFeedReading.count }.by(6)

      expect(page).to_not have_content("This school has no Rtone API feeds")
      expect(page).to have_content(rbee_meter_id)
      expect(school.low_carbon_hub_installations.count).to be 1
      expect(school.low_carbon_hub_installations.first.username).to eql username
      expect(school.low_carbon_hub_installations.first.password).to eql password
      expect(school.meters.count).to be 3

      click_on rbee_meter_id
      expect(page).to have_content(info_text)
      click_on "All Solar API feeds for #{school.name}"

      expect(page).to have_content("Delete")
      expect { click_on 'Delete' }.to change { Meter.count }.by(-3).and change { LowCarbonHubInstallation.count }.by(-1)

      expect(page).to have_content("This school has no Rtone API feeds")
    end

    it 'I can edit an installation' do
      expect(page).to have_content("This school has no Rtone API feeds")
      click_on 'New Rtone installation'

      allow(LowCarbonHubMeterReadings).to receive(:new).and_return(low_carbon_hub_api)

      fill_in(:low_carbon_hub_installation_rbee_meter_id, with: rbee_meter_id)
      fill_in(:low_carbon_hub_installation_username, with: username)
      fill_in(:low_carbon_hub_installation_password, with: password)

      expect { click_on 'Submit' }.to change { Meter.count }.by(3).and change { LowCarbonHubInstallation.count }.by(1).and change { AmrDataFeedReading.count }.by(6)

      expect(page).to have_content(rbee_meter_id)
      click_on 'Edit'
      expect(page).to have_content("Update Rtone API feed")

      expect(find_field(:low_carbon_hub_installation_username).value).to eql username
      expect(find_field(:low_carbon_hub_installation_password).value).to eql password

      fill_in(:low_carbon_hub_installation_username, with: "changed-user")
      fill_in(:low_carbon_hub_installation_password, with: "changed-pass")

      click_on 'Submit'
      expect(page).to have_content("Installation was updated")

      click_on 'Edit'
      expect(find_field(:low_carbon_hub_installation_username).value).to eql "changed-user"
      expect(find_field(:low_carbon_hub_installation_password).value).to eql "changed-pass"
    end

    it 'handles being run out of hours properly' do
      expect(page).to have_content("This school has no Rtone API feeds")
      click_on 'New Rtone installation'

      expect(Amr::LowCarbonHubInstallationFactory).to receive(:new).and_raise(EnergySparksUnexpectedStateException)

      click_on 'Submit'
      expect(page).to have_content("This school has no Rtone API feeds")
      expect(page).to have_content("Rtone API is not available at the moment")
    end

    it 'I delete a low carbon hub installation and meter readings get removed' do
      expect { create(:low_carbon_hub_installation_with_meters_and_validated_readings, school: school) }.to change { Meter.count }.by(3).and change { AmrValidatedReading.count }.by(3)

      visit school_meters_path(school)
      click_on 'Manage Solar API feeds'

      low_carbon_hub_installation = LowCarbonHubInstallation.first

      expect(page).to have_content low_carbon_hub_installation.rbee_meter_id
      expect { click_on 'Delete' }.to change { Meter.count }.by(-3).and change { LowCarbonHubInstallation.count }.by(-1).and change { AmrValidatedReading.count }.by(-3)
    end
  end
end
