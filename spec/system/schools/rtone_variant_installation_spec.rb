# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rtone variant installation management', :low_carbon_hub_installations do
  let!(:admin)                { create(:admin) }
  let!(:school)               { create(:school) }
  let!(:meter)                { create(:electricity_meter, school: school) }
  let(:rtone_meter_id) { '216057958' }
  let(:username)              { 'rtone-user' }
  let(:password)              { 'rtone-pass' }
  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :rtone_variant_api, source_type: :api) }
  let(:start_date)            { Date.parse('02/08/2016') }
  let(:end_date)              { start_date + 1.day }

  context 'when an admin' do
    before do
      sign_in(admin)
      visit school_meters_path(school)
    end

    it 'I can add, edit and delete an rtone variant installation' do
      click_on 'Solar Feeds'

      expect(page).to have_content('This school has no Rtone Variant API feeds')
      click_on 'New Rtone Variant API feed'

      fill_in(:rtone_variant_installation_rtone_meter_id, with: rtone_meter_id)
      fill_in(:rtone_variant_installation_username, with: username)
      fill_in(:rtone_variant_installation_password, with: password)

      expect { click_on 'Submit' }.to change(RtoneVariantInstallation, :count).by(1)

      expect(page).to have_no_content('This school has no Rtone Variant API feeds')
      expect(page).to have_content(rtone_meter_id)
      expect(school.rtone_variant_installations.first).to have_attributes(meter:, username:, password:)

      click_on 'Edit'
      expect(page).to have_content('Update Rtone Variant')

      select 'in1', from: 'Rtone Meter Type'
      fill_in(:rtone_variant_installation_username, with: 'changed-user')
      fill_in(:rtone_variant_installation_password, with: 'changed-pass')

      click_on 'Submit'

      expect(school.rtone_variant_installations.first.rtone_component_type).to eql 'in1'
      expect(school.rtone_variant_installations.first.password).to eql 'changed-pass'
      expect(school.rtone_variant_installations.first.username).to eql 'changed-user'

      expect(page).to have_content('Delete')
      expect { click_on 'Delete' }.to change(RtoneVariantInstallation, :count).by(-1)

      expect(page).to have_content('This school has no Rtone Variant API feeds')
    end

    context 'with existing installation' do
      let!(:installation) { create(:rtone_variant_installation, school: school) }

      before do
        click_on 'Solar Feeds'
      end

      it 'displays the check button with a question mark by default' do
        within "#rtone-variant-#{installation.id}-test" do
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
            find("#rtone-variant-#{installation.id}-test").click
            within "#rtone-variant-#{installation.id}-test" do
              expect(page).to have_css("i[class*='fa-circle-check']")
            end
          end
        end

        context 'when check returns false' do
          let(:ok) { false }

          it 'updates the button correctly' do
            find("#rtone-variant-#{installation.id}-test").click
            within "#rtone-variant-#{installation.id}-test" do
              expect(page).to have_css("i[class*='fa-circle-xmark']")
            end
          end
        end
      end

      context 'when submitting a loading job' do
        before do
          # do nothing
          allow(Solar::RtoneVariantLoaderJob).to receive(:perform_later).and_return(true)
        end

        it 'submits the job' do
          # ...but check the method is called
          expect(Solar::RtoneVariantLoaderJob).to receive(:perform_later).with(installation: installation,
                                                                               notify_email: admin.email)
          expect(page).to have_content('Run Loader')
          find("#rtone-variant-#{installation.id}-run-load").click
          expect(page).to have_content("Loading job has been submitted. An email will be sent to #{admin.email} when complete.")
        end
      end
    end
  end
end
