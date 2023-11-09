require 'rails_helper'
require 'dashboard'

RSpec.describe "Solar edge installation management", :solar_edge_installations, type: :system do
  let!(:admin)  { create(:admin) }
  let!(:school) { create(:school) }

  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :solar_edge_api) }

  let!(:mpan) { "123456789" }
  let!(:site_id) { "9999" }
  let!(:api_key) { "api_key" }

  context 'as an admin' do
    before do
      allow_any_instance_of(SolarEdgeAPI).to receive(:site_details).and_return({})
      allow_any_instance_of(SolarEdgeAPI).to receive(:site_start_end_dates).and_return([Date.yesterday, Time.zone.today])
      allow_any_instance_of(SolarEdgeAPI).to receive(:smart_meter_data).and_return({})

      sign_in(admin)
      visit school_meters_path(school)
    end

    context 'adding a new installation' do
      before do
        click_on 'Manage Solar API feeds'
      end

      it 'has no installation by default' do
        expect(page).to have_content("This school has no Solar Edge API feeds")
      end

      it 'allows an installation to be added' do
        click_on 'New Solar Edge API feed'
        expect(page).to have_content("Create a new Solar Edge API feed")

        fill_in(:solar_edge_installation_mpan, with: mpan)
        fill_in(:solar_edge_installation_site_id, with: site_id)
        fill_in(:solar_edge_installation_api_key, with: api_key)

        expect { click_on 'Submit'}.to change { SolarEdgeInstallation.count }.by(1)
        expect(page).to have_content("Solar Edge installation was successfully created")

        expect(SolarEdgeInstallation.first.mpan).to eql mpan
        expect(SolarEdgeInstallation.first.site_id).to eql site_id
        expect(SolarEdgeInstallation.first.api_key).to eql api_key
      end
    end

    context 'with existing installation' do
      let!(:installation) { create(:solar_edge_installation, school: school) }

      before do
        click_on 'Manage Solar API feeds'
      end

      it 'displays the feed config' do
        expect(page).not_to have_content("This school has no Solar Edge API feeds")
        expect(page).to have_content(installation.site_id)
      end

      it 'allows editing' do
        click_on 'Edit'
        expect(page).to have_content("Update Solar Edge API feed")
        fill_in(:solar_edge_installation_site_id, with: site_id)
        fill_in(:solar_edge_installation_api_key, with: api_key)
        click_on 'Submit'

        expect(page).to have_content("Solar Edge API feed was updated")

        expect(SolarEdgeInstallation.first.mpan).to eql installation.mpan
        expect(SolarEdgeInstallation.first.site_id).to eql site_id
        expect(SolarEdgeInstallation.first.api_key).to eql api_key
      end

      it 'allows deletion' do
        expect { click_on 'Delete'}.to change { SolarEdgeInstallation.count }.by(-1)
      end

      it 'allows viewing' do
        click_on(installation.mpan)
        expect(page).to have_content("site_details")
        expect(page).to have_content("dates")
        expect(page).to have_link("Data Period")
      end
    end

    context 'with an installation with meters' do
      let!(:installation) { create(:solar_edge_installation_with_meters_and_validated_readings, school: school) }

      before do
        click_on 'Manage Solar API feeds'
      end

      it 'removes meters and readings on deletion' do
        expect(AmrValidatedReading.count).to eql 3
        expect { click_on 'Delete' }.to change { Meter.count }.by(-3).and change { SolarEdgeInstallation.count }.by(-1).and change { AmrValidatedReading.count }.by(-3)
      end
    end
  end
end
