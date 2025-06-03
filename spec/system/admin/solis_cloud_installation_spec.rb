# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

RSpec.describe 'SolisCloud installation management' do
  include ActiveJob::TestHelper

  context 'when an admin' do
    let!(:admin) { create(:admin) }

    before do
      create(:amr_data_feed_config, identifier: 'solis-cloud')
      sign_in(admin)
    end

    context 'when adding a new installation' do
      before { visit admin_solis_cloud_installations_path }

      def create_new_installation_with_expectations
        click_on 'New SolisCloud API feed'
        expect(page).to have_content('New SolisCloud API feed')

        fill_in('API ID', with: 'api_id')
        fill_in('API secret', with: 'api_secret')

        expect { click_on 'Create SolisCloud API feed' }.to change(SolisCloudInstallation, :count).by(1)

        expect(page).to have_content('api_id')

        expect(SolisCloudInstallation.last.api_id).to eq('api_id')
        expect(SolisCloudInstallation.last.api_secret).to eq('api_secret')
      end

      it 'allows an installation to be added' do
        stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList')
          .to_return(headers: { 'content-type': 'application/json' },
                     body: { data: { records: [] } }.to_json)
        create_new_installation_with_expectations
        expect(SolisCloudInstallation.last.inverter_detail_list).not_to be_nil
        expect(page).to have_content('SolisCloud API feed was created')
      end

      it 'allows an installation to be added with incorrect credentials' do
        create_new_installation_with_expectations
        expect(page).to have_content('SolisCloud API feed was created but did not verify')
      end
    end

    context 'with an existing installation' do
      let!(:installation) { create(:solis_cloud_installation, inverter_detail_list: [{ sn: '123' }]) }
      let!(:school) { create(:school) }

      before { visit admin_solis_cloud_installations_path }

      it 'displays the feed config' do
        expect(page).to have_content(installation.api_id)
      end

      it 'allows editing' do
        click_on 'Edit'
        expect(page).to have_content('Edit SolisCloud API feed')
        fill_in(:solis_cloud_installation_api_id, with: 'new_id')
        click_on 'Update SolisCloud API feed'
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

      it 'allows creating a meter' do
        click_on(installation.api_id)
        select(school.name, from: 'inverters_123')
        click_on('Create')
        expect(installation.meters.pluck(:meter_serial_number)).to eq(['123'])
      end

      it 'allows creating a meter with school as station name' do
        installation.update!(inverter_detail_list: [{ sn: '1234', stationName: school.name }])
        click_on(installation.api_id)
        click_on('Create')
        expect(installation.meters.pluck(:meter_serial_number)).to eq(['1234'])
      end

      def expect_icon(icon)
        within "#check-button-#{installation.id}" do
          expect(page).to have_css("i[class*='#{icon}']")
        end
      end

      it 'displays the check button with a question mark by default' do
        expect_icon('fa-circle-question')
        within "#check-button-#{installation.id}" do
          expect(page).to have_content('Check')
          expect(page).to have_css("i[class*='fa-circle-question']")
        end
      end

      context 'when checking an installation', :js do
        before { find("#check-button-#{installation.id}").click }

        it 'succeeds' do
          stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList')
            .to_return(headers: { 'content-type': 'application/json' },
                       body: { data: { records: [{}] } }.to_json)
          find("#check-button-#{installation.id}").click
          expect_icon('fa-circle-check')
        end

        it 'fails' do
          stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList')
            .to_return(status: 403)
          find("#check-button-#{installation.id}").click
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
