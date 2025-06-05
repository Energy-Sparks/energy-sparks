# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

RSpec.describe 'Low carbon hub management', :low_carbon_hub_installations do
  include_context 'low carbon hub data'

  let!(:admin) { create(:admin) }

  context 'when an admin' do
    before do
      sign_in(admin)
      visit school_meters_path(school)
    end

    context 'with no api feeds' do
      before do
        click_on 'Solar Feeds'
      end

      it 'I can add and delete a low carbon hub installation' do
        expect(page).to have_content('This school has no Rtone API feeds')
        click_on 'New Rtone API feed'

        allow(DataFeeds::LowCarbonHubMeterReadings).to receive(:new).with(username,
                                                                          password).and_return(low_carbon_hub_api)

        fill_in(:low_carbon_hub_installation_rbee_meter_id, with: rbee_meter_id)
        fill_in(:low_carbon_hub_installation_username, with: username)
        fill_in(:low_carbon_hub_installation_password, with: password)

        expect { click_on 'Submit' }.to change(Meter, :count).by(3)
                                    .and change(LowCarbonHubInstallation, :count).by(1)
                                    .and change(AmrDataFeedReading, :count).by(6)

        expect(page).to have_no_content('This school has no Rtone API feeds')
        expect(page).to have_content(rbee_meter_id)
        expect(school.low_carbon_hub_installations.count).to be 1
        expect(school.low_carbon_hub_installations.first.username).to eql username
        expect(school.low_carbon_hub_installations.first.password).to eql password
        expect(school.meters.count).to be 3

        click_on rbee_meter_id
        expect(page).to have_content(info_text)
        click_on 'All Solar API feeds'

        expect(page).to have_content('Delete')
        expect { click_on 'Delete' }.to change(Meter, :count).by(-3).and change(LowCarbonHubInstallation, :count).by(-1)

        expect(page).to have_content('This school has no Rtone API feeds')
      end

      it 'I can edit an installation' do
        expect(page).to have_content('This school has no Rtone API feeds')
        click_on 'New Rtone API feed'

        allow(DataFeeds::LowCarbonHubMeterReadings).to receive(:new).with(username,
                                                                          password).and_return(low_carbon_hub_api)

        fill_in(:low_carbon_hub_installation_rbee_meter_id, with: rbee_meter_id)
        fill_in(:low_carbon_hub_installation_username, with: username)
        fill_in(:low_carbon_hub_installation_password, with: password)

        expect { click_on 'Submit' }.to change(Meter, :count).by(3)
                                    .and change(LowCarbonHubInstallation, :count).by(1)
                                    .and change(AmrDataFeedReading, :count).by(6)

        expect(page).to have_content(rbee_meter_id)
        click_on 'Edit'
        expect(page).to have_content('Update Rtone')

        expect(find_field(:low_carbon_hub_installation_username).value).to eql username
        expect(find_field(:low_carbon_hub_installation_password).value).to eql password

        fill_in(:low_carbon_hub_installation_username, with: 'changed-user')
        fill_in(:low_carbon_hub_installation_password, with: 'changed-pass')

        click_on 'Submit'
        expect(page).to have_content('API feed was updated')

        click_on 'Edit'
        expect(find_field(:low_carbon_hub_installation_username).value).to eql 'changed-user'
        expect(find_field(:low_carbon_hub_installation_password).value).to eql 'changed-pass'
      end

      it 'handles being run out of hours properly' do
        expect(page).to have_content('This school has no Rtone API feeds')
        click_on 'New Rtone API feed'

        allow(Solar::LowCarbonHubInstallationFactory).to receive(:new).and_raise(EnergySparksUnexpectedStateException)

        click_on 'Submit'
        expect(page).to have_content('This school has no Rtone API feeds')
        expect(page).to have_content('Rtone API is not available at the moment')
      end

      it 'I delete a low carbon hub installation and meter readings get removed' do
        expect do
          create(:low_carbon_hub_installation_with_meters_and_validated_readings,
                 school: school)
        end.to change(Meter, :count).by(3).and change(AmrValidatedReading, :count).by(3)

        visit school_meters_path(school)
        click_on 'Solar Feeds'

        low_carbon_hub_installation = LowCarbonHubInstallation.first

        expect(page).to have_content low_carbon_hub_installation.rbee_meter_id
        expect do
          click_on 'Delete'
        end.to change(Meter,
                      :count).by(-3).and change(LowCarbonHubInstallation,
                                                :count).by(-1).and change(AmrValidatedReading, :count).by(-3)
      end
    end

    context 'with existing installation' do
      let!(:installation) { create(:low_carbon_hub_installation, school: school) }

      before do
        click_on 'Solar Feeds'
      end

      it 'displays the check button with a question mark by default' do
        within "#low-carbon-hub-#{installation.id}-test" do
          expect(page).to have_content('Check')
          expect(page).to have_css("i[class*='fa-circle-question']")
        end
      end

      context 'when checking an installation', :js do
        before do
          allow(Solar::LowCarbonHubInstallationFactory).to receive(:check).and_return(ok)
        end

        context 'when check returns true' do
          let(:ok) { true }

          it 'updates the button correctly' do
            find("#low-carbon-hub-#{installation.id}-test").click
            within "#low-carbon-hub-#{installation.id}-test" do
              expect(page).to have_css("i[class*='fa-circle-check']")
            end
          end
        end

        context 'when check returns false' do
          let(:ok) { false }

          it 'updates the button correctly' do
            find("#low-carbon-hub-#{installation.id}-test").click
            within "#low-carbon-hub-#{installation.id}-test" do
              expect(page).to have_css("i[class*='fa-circle-xmark']")
            end
          end
        end
      end

      context 'when submitting a loading job' do
        before do
          # do nothing
          allow(Solar::LowCarbonHubLoaderJob).to receive(:perform_later).and_return(true)
        end

        it 'submits the job' do
          # ...but check the method is called
          expect(Solar::LowCarbonHubLoaderJob).to receive(:perform_later).with(installation: installation,
                                                                               notify_email: admin.email)
          expect(page).to have_content('Run Loader')
          find("#low-carbon-hub-#{installation.id}-run-load").click
          expect(page).to have_content("Loading job has been submitted. An email will be sent to #{admin.email} when complete.")
        end
      end
    end
  end
end
