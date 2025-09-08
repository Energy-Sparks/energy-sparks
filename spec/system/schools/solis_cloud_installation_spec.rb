# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

RSpec.describe 'SolisCloud installation management' do
  let(:school) { create(:school) }

  include ActiveJob::TestHelper

  context 'when an admin' do
    let!(:admin) { create(:admin) }

    before do
      create(:amr_data_feed_config, identifier: 'solis-cloud')
      sign_in(admin)
    end

    context 'when adding a new installation' do
      before { visit school_solar_feeds_configuration_index_path(school) }

      def create_new_installation_with_expectations
        click_on 'New SolisCloud API feed'
        expect(page).to have_content('new SolisCloud API feed')

        fill_in('API ID', with: 'api_id')
        fill_in('API Secret', with: 'api_secret')

        expect { click_on 'Submit' }.to change(SolisCloudInstallation, :count).by(1)

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
        expect(page).to have_content('SolisCloud API feed was successfully created')
      end

      it 'allows an installation to be added with incorrect credentials' do
        stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList').to_return(status: 403)
        create_new_installation_with_expectations
        expect(page).to have_content('SolisCloud API feed was created but did not verify')
      end
    end

    context 'with an existing installation' do
      let!(:installation) do
        installation = create(:solis_cloud_installation, inverter_detail_list: [{ sn: '123' }])
        installation.schools << school
        installation
      end

      before { visit school_solar_feeds_configuration_index_path(school) }

      it 'displays the feed config' do
        expect(page).to have_content(installation.api_id)
      end

      it 'allows editing' do
        click_on('Edit')
        expect(page).to have_content('Update SolisCloud API feed')
        fill_in(:solis_cloud_installation_api_id, with: 'new_id')
        click_on 'Submit'
        expect(page).to have_content('SolisCloud API feed was updated')
        expect(page).to have_content('new_id')
        expect(SolisCloudInstallation.last.api_id).to eq('new_id')
      end

      it 'removes meters and readings on deletion' do
        create(:electricity_meter_with_validated_reading, solis_cloud_installation: installation, school:)
        expect(AmrValidatedReading.count).to eq(1)
        expect { click_on 'Delete' }.to change(Meter, :count).by(-1)
                                    .and change(SolisCloudInstallation, :count).by(-1)
                                    .and change(AmrValidatedReading, :count).by(-1)
      end

      it 'allows creating a meter' do
        click_on('Edit')
        click_on('Assign')
        expect(installation.meters.pluck(:meter_serial_number)).to eq(['123'])
      end

      it 'allows creating a meter with school as station name' do
        installation.update!(inverter_detail_list: [{ sn: '1234', stationName: school.name }])
        click_on('Edit')
        click_on('Assign')
        expect(installation.meters.pluck(:meter_serial_number)).to eq(['1234'])
        expect(installation.meters.first.name).to include(school.name)
      end

      def check_button_locator
        "a#solis-cloud-#{installation.id}-test"
      end

      def expect_icon(icon)
        within check_button_locator do
          expect(page).to have_css("i[class*='#{icon}']")
        end
      end

      it 'displays the check button with a question mark by default' do
        expect(page).to have_content('Check')
        expect_icon('fa-circle-question')
      end

      context 'when checking an installation', :js do
        it 'succeeds' do
          stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList')
            .to_return(headers: { 'content-type': 'application/json' },
                       body: { data: { records: [{}] } }.to_json)
          find(check_button_locator).click
          expect_icon('fa-circle-check')
        end

        it 'fails' do
          stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList').to_return(status: 403)
          find(check_button_locator).click
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
