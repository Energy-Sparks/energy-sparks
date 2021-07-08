require 'rails_helper'
require 'dashboard'

RSpec.describe "Rtone variant installation management", :low_carbon_hub_installations, type: :system do

  let!(:admin)                { create(:admin) }
  let!(:school)               { create(:school) }
  let!(:meter)                { create(:electricity_meter, school: school)}
  let(:rtone_meter_id)         { "216057958" }
  let(:username)              { "rtone-user" }
  let(:password)              { "rtone-pass" }
  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :rtone_variant_api) }
  let(:start_date)            { Date.parse('02/08/2016') }
  let(:end_date)              { start_date + 1.day }

  context 'as an admin' do
    before(:each) do
      sign_in(admin)
      visit school_meters_path(school)
      click_on 'Manage Solar API feeds'
    end

    it 'I can add, edit and delete an rtone variant installation' do
      expect(page).to have_content("This school has no Rtone Variant API feeds")
      click_on 'New Rtone Variant API feed'

      fill_in(:rtone_variant_installation_rtone_meter_id, with: rtone_meter_id)
      fill_in(:rtone_variant_installation_username, with: username)
      fill_in(:rtone_variant_installation_password, with: password)

      expect { click_on 'Submit' }.to change { RtoneVariantInstallation.count }.by(1)

      expect(page).to_not have_content("This school has no Rtone Variant API feeds")
      expect(page).to have_content(rtone_meter_id)
      expect(school.rtone_variant_installations.first.meter).to eql meter
      expect(school.rtone_variant_installations.first.username).to eql username
      expect(school.rtone_variant_installations.first.password).to eql password

      click_on 'Edit'
      expect(page).to have_content("Update Rtone Variant API feed")

      select 'in1', from: 'Rtone Meter Type'
      fill_in(:rtone_variant_installation_username, with: "changed-user")
      fill_in(:rtone_variant_installation_password, with: "changed-pass")

      click_on 'Submit'

      expect(school.rtone_variant_installations.first.rtone_component_type).to eql "in1"
      expect(school.rtone_variant_installations.first.password).to eql "changed-pass"
      expect(school.rtone_variant_installations.first.username).to eql "changed-user"

      expect(page).to have_content("Delete")
      expect { click_on 'Delete' }.to change { RtoneVariantInstallation.count }.by(-1)

      expect(page).to have_content("This school has no Rtone Variant API feeds")
    end

  end
end
