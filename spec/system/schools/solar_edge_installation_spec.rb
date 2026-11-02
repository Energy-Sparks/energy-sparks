# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

RSpec.describe 'Solar edge installation management', :solar_edge_installations do
  include ActiveJob::TestHelper

  let!(:admin)  { create(:admin) }
  let!(:school) { create(:school) }

  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :solar_edge_api, source_type: :api) }

  let!(:mpan) { '123456789' }
  let!(:site_id) { '9999' }

  context 'when an admin' do
    before do
      sign_in(admin)
      visit school_meters_path(school)
    end

    context 'with existing installation' do
      let!(:installation) { create(:solar_edge_installation, :unconsented, school:) }

      before do
        click_on 'Solar Feeds'
      end

      it 'displays the feed config' do
        expect(page).to have_no_text('This school has no Solar Edge sites')
        expect(page).to have_text(installation.site_id)
      end

      context 'with unconsented SolarEdge site' do
        let!(:installation) { create(:solar_edge_installation, :unconsented, school:) }

        it 'does not display the check button' do
          expect(page).to have_no_text('Check')
        end

        context 'when editing' do
          before { click_on 'Edit' }

          it 'can update the loading status' do
            expect(page).to have_text('Update SolarEdge API feed')

            uncheck(:solar_edge_installation_active)
            click_on 'Submit'

            expect(page).to have_text('SolarEdge API feed was updated')
            expect(SolarEdgeInstallation.first).to have_attributes(active: false)
          end
        end
      end

      context 'with consented SolarEdge site' do
        let!(:installation) { create(:solar_edge_installation, school:) }
        let(:site_id) { installation.site_id }

        include_context 'with a stubbed SolarEdge site details request'
        include_context 'with a stubbed SolarEdge date request'
        include_context 'with a stubbed SolarEdge inventory request'

        context 'when editing' do
          before { click_on 'Edit' }

          it 'allows editing' do
            expect(page).to have_text('Update SolarEdge API feed')

            uncheck(:solar_edge_installation_active)
            click_on 'Submit'

            expect(page).to have_text('SolarEdge API feed was updated')
            expect(SolarEdgeInstallation.first).to have_attributes(active: false)
          end
        end

        it 'displays the check button with a question mark' do
          within "#solar-edge-#{installation.id}-test" do
            expect(page).to have_text('Check')
            expect(page).to have_css("i[class*='fa-circle-question']")
          end
        end

        context 'when checking an installation', :js do
          context 'when check returns true' do
            include_context 'with a successful SolarEdge token request'

            it 'updates the button correctly' do
              find("#solar-edge-#{installation.id}-test").click
              within "#solar-edge-#{installation.id}-test" do
                expect(page).to have_css("i[class*='fa-circle-check']")
              end
            end
          end

          context 'when check returns false' do
            let!(:installation) { create(:solar_edge_installation, :with_expired_access_token, school:) }

            include_context 'with a failed SolarEdge token request'

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

      it 'allows deletion' do
        expect { click_on 'Delete' }.to change(SolarEdgeInstallation, :count).by(-1)
      end

      it 'allows viewing' do
        click_on(installation.site_id)
        expect(page).to have_text('site_detail')
        expect(page).to have_text('dates')
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

    context 'when requesting a connection' do
      let!(:school) { create(:school, :with_trust) }

      let!(:school_admin) { create(:school_admin, school:) }
      let!(:staff) { create(:staff, school:) }
      let!(:group_admin) { create(:group_admin, school_group: school.organisation_group) }

      before { click_on 'Solar Feeds' }

      it 'has link to request connection' do
        expect(page).to have_link('Request SolarEdge Connection',
                                  href: connect_school_solar_edge_installations_path(school))
      end

      context 'when viewing form' do
        before { click_on 'Request SolarEdge Connection' }

        it 'displays school and group users' do
          expect(page).to have_text(staff.name)
          expect(page).to have_text(staff.staff_role.title)
          expect(page).to have_text(school_admin.name)
          expect(page).to have_text(school_admin.staff_role.title)
          expect(page).to have_text(group_admin.name)
        end

        shared_examples 'it sends the email request' do
          before { perform_enqueued_jobs }

          let(:email) { ActionMailer::Base.deliveries.first }

          it 'sends correct email' do
            expect(page).to have_text('Connection has been requested')
            expect(email.to).to include(email_address)
            expect(email.subject).to eq('Request for access to data from your SolarEdge monitoring system')
          end
        end

        context 'when no user specified' do
          before { click_on 'Request connection' }

          it { expect(page).to have_text('You must choose at least one user or specify an email address') }
        end

        context 'when emailing a user' do
          before do
            find(:css, "#request_connection_user_ids_#{school_admin.id}").set(true)
            click_on 'Request connection'
          end

          it_behaves_like 'it sends the email request' do
            let(:email_address) { school_admin.email }
          end
        end

        context 'when specifying an email address' do
          before do
            fill_in 'Email', with: 'user@example.org'
            click_on 'Request connection'
          end

          it_behaves_like 'it sends the email request' do
            let(:email_address) { 'user@example.org' }
          end
        end

        context 'when specifying multiple contacts' do
          before do
            find(:css, "#request_connection_user_ids_#{school_admin.id}").set(true)
            fill_in 'Email', with: 'user@example.org'

            click_on 'Request connection'
          end

          it 'sends separate emails' do
            perform_enqueued_jobs
            recipients = ActionMailer::Base.deliveries.map(&:to).flatten
            expect(recipients).to contain_exactly(school_admin.email, 'user@example.org')
          end
        end
      end
    end
  end
end
