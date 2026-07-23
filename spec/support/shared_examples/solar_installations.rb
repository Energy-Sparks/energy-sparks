# frozen_string_literal: true

require 'rails_helper'

shared_examples 'solar installation management' do
  include ActiveJob::TestHelper

  let(:school) { create(:school) }
  let(:admin) { create(:admin) }

  before do
    create(:amr_data_feed_config, identifier: installation_type.underscore.dasherize)
    sign_in(admin)
  end

  context 'when adding a new installation' do
    before { visit school_solar_feeds_configuration_index_path(school) }

    context 'with correct API details' do
      before { stub_successful_verify }

      it 'allows an installation to be added' do
        click_on "New #{installation_type} API feed"
        expect(page).to have_text("Add a new #{installation_type} API feed")
        create_new_installation
        uncheck('Active')
        expect { click_on 'Submit' }.to change(installation_model, :count).by(1)
        check_installation
        expect(page).to have_text("#{installation_type} API feed was verified")
      end
    end

    context 'with incorrect API details' do
      before { stub_unsuccessful_verify }

      it 'allows an installation to be added with incorrect credentials' do
        click_on "New #{installation_type} API feed"
        create_new_installation
        expect { click_on 'Submit' }.to change(installation_model, :count).by(1)
        expect(page).to have_text("#{installation_type} API feed did not verify. Check API details and try again.")
      end
    end
  end

  context 'with an existing installation' do
    before do
      if installation.meters.any?
        create(:amr_validated_reading, meter: installation.meters.first)
      else
        create(:electricity_meter_with_validated_reading, solis_cloud_installation: installation, school:)
      end
      visit school_solar_feeds_configuration_index_path(school)
    end

    it 'displays the feed config' do
      expect(page).to have_text(installation_key)
    end

    it 'allows editing' do
      click_on('Edit')
      expect(page).to have_text("Update #{installation_type} API feed")
      edit
      click_on 'Submit'
      expect(page).to have_text("#{installation_type} API feed was updated")
      check_edit
    end

    it 'removes meters and readings on deletion' do
      expect(AmrValidatedReading.count).to eq(1)
      expect { click_on 'Delete' }.to change(Meter, :count).by(-1)
                                  .and change(installation_model, :count).by(-1)
                                  .and change(AmrValidatedReading, :count).by(-1)
    end

    it 'allows assigning a meter' do
      click_on('Edit')
      expect { click_on('Assign') }.to change(Meter, :count).by(1)
      expect(installation.meters.pluck(:meter_serial_number)).to include('123')
    end

    # it 'allows creating a meter with school as station name' do
    #   installation.update!(inverter_detail_list: [{ sn: '1234', stationName: school.name }])
    #   click_on('Edit')
    #   click_on('Assign')
    #   expect(installation.meters.pluck(:meter_serial_number)).to eq(['1234'])
    #   expect(installation.meters.first.name).to include(school.name)
    # end

    it 'allows unassigning a meter' do
      click_on('Edit')
      expect { click_on('Unassign') }.to change(Meter, :count).by(-1)
    end

    context 'with the check button' do
      def check_button_locator
        "a##{installation_type.underscore.dasherize}-#{installation.id}-test"
      end

      def expect_icon(icon)
        within check_button_locator do
          expect(page).to have_css("i[class*='#{icon}']")
        end
      end

      it 'displays the check button with a question mark by default' do
        expect(page).to have_text('Check')
        expect_icon('fa-circle-question')
      end

      context 'when checking an installation', :js do
        it 'succeeds' do
          stub_successful_verify
          find(check_button_locator).click
          expect_icon('fa-circle-check')
        end

        it 'fails' do
          stub_unsuccessful_verify
          find(check_button_locator).click
          expect_icon('fa-circle-xmark')
        end
      end
    end

    context 'when submitting a loading job' do
      it 'submits the job' do
        expect { click_on 'Run Loader' }.to \
          have_enqueued_job(loader_job).with(installation:, notify_email: admin.email)
        expect(page).to have_text('Loading job has been submitted. ' \
                                  "An email will be sent to #{admin.email} when complete.")
      end
    end
  end
end
