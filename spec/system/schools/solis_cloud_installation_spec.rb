# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

RSpec.describe 'SolisCloud installation management' do
  include ActiveJob::TestHelper

  let!(:school) { create(:school) }
  let(:station_list) { [{ id: 1 }, { id: 2 }] }

  context 'when an admin' do
    let!(:admin) { create(:admin) }

    before do
      create(:amr_data_feed_config, identifier: 'solis-cloud')
      sign_in(admin)
      visit school_meters_path(school)
    end

    context 'when adding a new installation' do
      before { click_on 'Solar Feeds' }

      it 'has no installation by default' do
        expect(page).to have_content('This school has no SolisCloud sites')
      end

      def create_new_installation_with_expectations
        click_on 'New SolisCloud API feed'
        expect(page).to have_content('Add a new SolisCloud Site')

        fill_in(:solis_cloud_installation_api_id, with: 'api_id')
        fill_in(:solis_cloud_installation_api_secret, with: 'api_secret')

        expect { click_on 'Submit' }.to change(SolisCloudInstallation, :count).by(1)

        expect(page).to have_content('api_id')
        expect(page).to have_content('api_secret')

        expect(SolisCloudInstallation.last.api_id).to eq('api_id')
        expect(SolisCloudInstallation.last.api_secret).to eq('api_secret')
      end

      it 'allows an installation to be added' do
        stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/userStationList')
          .to_return(headers: { 'content-type': 'application/json' },
                     body: { data: { page: { records: station_list } } }.to_json)
        create_new_installation_with_expectations
        expect(page).to have_content('SolisCloud installation was successfully created')
      end

      it 'allows an installation to be added with incorrect credentials' do
        stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/userStationList')
          .to_return(status: 403)
        create_new_installation_with_expectations
        expect(page).to have_content('SolisCloud installation was created')
      end
    end

    context 'with an existing installation' do
      let!(:installation) { create(:solis_cloud_installation, school: school, station_list:) }

      before { click_on 'Solar Feeds' }

      it 'displays the feed config' do
        expect(page).to have_content(installation.api_id)
      end

      it 'allows editing' do
        click_on 'Edit'
        expect(page).to have_content('Update SolisCloud Site')

        fill_in(:solis_cloud_installation_api_id, with: 'new_id')
        click_on 'Submit'

        expect(page).to have_content('SolisCloud API feed was updated')
        expect(page).to have_content('new_id')
        expect(SolisCloudInstallation.last.api_id).to eq('new_id')
      end

      it 'allows deletion' do
        expect { click_on 'Delete' }.to change(SolisCloudInstallation, :count).by(-1)
      end

      it 'removes meters and readings on deletion' do
        create(:electricity_meter_with_validated_reading, solis_cloud_installation: installation)
        expect(AmrValidatedReading.count).to eq(1)
        expect { click_on 'Delete' }.to change(Meter, :count).by(-1)
                                    .and change(SolisCloudInstallation, :count).by(-1)
                                    .and change(AmrValidatedReading, :count).by(-1)
      end

      it 'allows viewing' do
        click_on(installation.api_id)
        expect(page).to have_content('Station 1')
      end

      it 'displays the check button with a question mark by default' do
        within "#solis-cloud-#{installation.id}-test" do
          expect(page).to have_content('Check')
          expect(page).to have_css("i[class*='fa-circle-question']")
        end
      end

      context 'when checking an installation', :js do
        def expect_icon(icon)
          find("#solis-cloud-#{installation.id}-test").click
          within "#solis-cloud-#{installation.id}-test" do
            expect(page).to have_css("i[class*='#{icon}']")
          end
        end

        it 'succeeds' do
          stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/userStationList')
            .to_return(headers: { 'content-type': 'application/json' },
                       body: { data: { page: { records: station_list } } }.to_json)
          expect_icon('fa-circle-check')
        end

        it 'fails' do
          stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/userStationList')
            .to_return(status: 403)
          expect_icon('fa-circle-xmark')
        end
      end

      context 'when submitting a loading job' do
        it 'submits the job' do
          expect { click_on 'Run Loader' }.to \
            have_enqueued_job(Solar::SolisCloudLoaderJob).with(installation:, notify_email: admin.email)
          expect(page).to have_content('Loading job has been submitted. ' \
                                       "An email will be sent to #{admin.email} when complete.")
        end
      end
    end
  end
end
