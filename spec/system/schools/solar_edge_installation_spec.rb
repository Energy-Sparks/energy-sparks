# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

RSpec.describe 'Solar edge installation management', :solar_edge_installations do
  let!(:admin)  { create(:admin) }
  let!(:school) { create(:school) }

  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :solar_edge_api, source_type: :api) }

  let!(:mpan) { '123456789' }
  let!(:site_id) { '9999' }
  let!(:api_key) { 'api_key' }

  context 'when an admin' do
    before do
      solar_edge_api = instance_double(DataFeeds::SolarEdgeApi,
                                       site_details: '',
                                       site_start_end_dates: [Date.new(2025), Date.new(2026)],
                                       smart_meter_data: {})
      allow(DataFeeds::SolarEdgeApi).to receive(:new).with(api_key).and_return(solar_edge_api)
      sign_in(admin)
      visit school_meters_path(school)
    end

    context 'when adding a new installation' do
      before do
        click_on 'Solar Feeds'
      end

      it 'has no installation by default' do
        expect(page).to have_text('This school has no Solar Edge sites')
      end

      it 'allows an installation to be added' do
        click_on 'New Solar Edge API feed'
        expect(page).to have_text('Add a new SolarEdge API feed')

        fill_in(:solar_edge_installation_mpan, with: mpan)
        fill_in(:solar_edge_installation_site_id, with: site_id)
        fill_in(:solar_edge_installation_api_key, with: api_key)
        uncheck('Active')

        expect { click_on 'Submit' }.to change(SolarEdgeInstallation, :count).by(1)
        expect(page).to have_text('SolarEdge API feed was successfully created')

        expect(page).to have_text(mpan)
        expect(page).to have_text(site_id)
        expect(page).to have_text(api_key)

        expect(SolarEdgeInstallation.first).to \
          have_attributes(mpan:, site_id:, api_key:, amr_data_feed_config:, active: false,
                          information: { 'site_details' => '', 'dates' => %w[2025-01-01 2026-01-01] })
      end
    end

    context 'with existing installation' do
      let!(:api_key) { "new_#{super()}" }
      let!(:installation) { create(:solar_edge_installation, school:) }

      before { click_on 'Solar Feeds' }

      it 'displays the feed config' do
        expect(page).to have_no_text('This school has no Solar Edge sites')
        expect(page).to have_text(installation.site_id)
      end

      it 'allows editing' do
        click_on 'Edit'
        expect(page).to have_text('Update SolarEdge API feed')

        expect(find_by_id('solar_edge_installation_mpan').disabled?).to be true
        expect(find_by_id('solar_edge_installation_site_id').disabled?).to be true

        fill_in(:solar_edge_installation_api_key, with: api_key)
        click_on 'Submit'

        expect(page).to have_text('SolarEdge API feed was updated')
        expect(page).to have_text(api_key)
        expect(SolarEdgeInstallation.first).to \
          have_attributes(api_key:,
                          information: { 'site_details' => '', 'dates' => %w[2025-01-01 2026-01-01] })
      end

      it 'allows deletion' do
        expect { click_on 'Delete' }.to change(SolarEdgeInstallation, :count).by(-1)
      end

      it 'allows viewing' do
        click_on(installation.mpan)
        expect(page).to have_text('site_details')
        expect(page).to have_text('dates')
        expect(page).to have_link('Data Period')
      end

      it 'displays the check button with a question mark by default' do
        within "#solar-edge-#{installation.id}-test" do
          expect(page).to have_text('Check')
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
          expect(Solar::SolarEdgeLoaderJob).to receive(:perform_later).with(installation:, notify_email: admin.email)
          expect(page).to have_text('Run Loader')
          find("#solar-edge-#{installation.id}-run-load").click
          expect(page).to have_text("Loading job has been submitted. An email will be sent to #{admin.email} when complete.")
        end
      end
    end

    context 'with an installation with meters' do
      let!(:installation) { create(:solar_edge_installation_with_meters_and_validated_readings, school:) }

      before { click_on 'Solar Feeds' }

      it 'removes meters and readings on deletion' do
        expect(AmrValidatedReading.count).to be 3
        expect { click_on 'Delete' }.to change(Meter, :count).by(-3)
                                    .and change(SolarEdgeInstallation, :count).by(-1)
                                    .and change(AmrValidatedReading, :count).by(-3)
      end
    end
  end
end
