require 'rails_helper'
require 'dashboard'

RSpec.describe 'Solar edge installation management', :solar_edge_installations, type: :system do
  let!(:admin)  { create(:admin) }
  let!(:school) { create(:school) }

  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :solar_edge_api, source_type: :api) }

  let!(:mpan) { '123456789' }
  let!(:site_id) { '9999' }
  let!(:api_key) { 'api_key' }

  context 'when an admin' do
    before do
      allow_any_instance_of(DataFeeds::SolarEdgeApi).to receive(:site_details).and_return({})
      allow_any_instance_of(DataFeeds::SolarEdgeApi).to receive(:site_start_end_dates).and_return([Date.yesterday, Time.zone.today])
      allow_any_instance_of(DataFeeds::SolarEdgeApi).to receive(:smart_meter_data).and_return({})

      sign_in(admin)
      visit school_meters_path(school)
    end

    context 'when adding a new installation' do
      before do
        click_on 'Solar Feeds'
      end

      it 'has no installation by default' do
        expect(page).to have_content('This school has no Solar Edge sites')
      end

      it 'allows an installation to be added' do
        click_on 'New Solar Edge API feed'
        expect(page).to have_content('Add a new SolarEdge API feed')

        fill_in(:solar_edge_installation_mpan, with: mpan)
        fill_in(:solar_edge_installation_site_id, with: site_id)
        fill_in(:solar_edge_installation_api_key, with: api_key)

        expect { click_on 'Submit'}.to change(SolarEdgeInstallation, :count).by(1)
        expect(page).to have_content('SolarEdge API feed was successfully created')

        expect(page).to have_content(mpan)
        expect(page).to have_content(site_id)
        expect(page).to have_content(api_key)

        expect(SolarEdgeInstallation.first.mpan).to eql mpan
        expect(SolarEdgeInstallation.first.site_id).to eql site_id
        expect(SolarEdgeInstallation.first.api_key).to eql api_key
      end
    end

    context 'with existing installation' do
      let!(:installation) { create(:solar_edge_installation, school: school) }

      let(:new_api_key)   { '99999' }

      before do
        click_on 'Solar Feeds'
      end

      it 'displays the feed config' do
        expect(page).not_to have_content('This school has no Solar Edge sites')
        expect(page).to have_content(installation.site_id)
      end

      it 'allows editing' do
        click_on 'Edit'
        expect(page).to have_content('Update SolarEdge API feed')

        expect(find('#solar_edge_installation_mpan').disabled?).to be true
        expect(find('#solar_edge_installation_site_id').disabled?).to be true

        fill_in(:solar_edge_installation_api_key, with: new_api_key)
        click_on 'Submit'

        expect(page).to have_content('SolarEdge API feed was updated')
        expect(page).to have_content(new_api_key)
        expect(SolarEdgeInstallation.first.api_key).to eql new_api_key
      end

      it 'allows deletion' do
        expect { click_on 'Delete'}.to change(SolarEdgeInstallation, :count).by(-1)
      end

      it 'allows viewing' do
        click_on(installation.mpan)
        expect(page).to have_content('site_details')
        expect(page).to have_content('dates')
        expect(page).to have_link('Data Period')
      end

      it 'displays the check button with a question mark by default' do
        within "#solar-edge-#{installation.id}-test" do
          expect(page).to have_content('Check')
          expect(page).to have_css("i[class*='fa-circle-question']")
        end
      end

      context 'when checking an installation', :js do
        before do
          allow(Solar::SolarEdgeInstallationFactory).to receive(:check).and_return(ok)
        end

        context 'when check returns true' do
          let(:ok) { true }

          it 'updates the button correctly' do
            find("#solar-edge-#{installation.id}-test").click
            within "#solar-edge-#{installation.id}-test" do
              expect(page).to have_css("i[class*='fa-circle-check']")
            end
          end
        end

        context 'when check returns false' do
          let(:ok) { false }

          it 'updates the button correctly' do
            find("#solar-edge-#{installation.id}-test").click
            within "#solar-edge-#{installation.id}-test" do
              expect(page).to have_css("i[class*='fa-circle-xmark']")
            end
          end
        end
      end

      context 'when submitting a loading job' do
        before do
          # do nothing
          allow(Solar::SolarEdgeLoaderJob).to receive(:perform_later).and_return(true)
        end

        it 'submits the job' do
          # ...but check the method is called
          expect(Solar::SolarEdgeLoaderJob).to receive(:perform_later).with(installation: installation, notify_email: admin.email)
          expect(page).to have_content('Run Loader')
          find("#solar-edge-#{installation.id}-run-load").click
          expect(page).to have_content("Loading job has been submitted. An email will be sent to #{admin.email} when complete.")
        end
      end
    end

    context 'with an installation with meters' do
      let!(:installation) { create(:solar_edge_installation_with_meters_and_validated_readings, school: school) }

      before do
        click_on 'Solar Feeds'
      end

      it 'removes meters and readings on deletion' do
        expect(AmrValidatedReading.count).to be 3
        expect { click_on 'Delete' }.to change(Meter, :count).by(-3).and change(SolarEdgeInstallation, :count).by(-1).and change(AmrValidatedReading, :count).by(-3)
      end
    end
  end
end
