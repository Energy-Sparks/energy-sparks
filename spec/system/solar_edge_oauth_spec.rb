# frozen_string_literal: true

require 'rails_helper'

describe 'SolarEdge Oauth workflow' do
  include ActiveJob::TestHelper

  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :solar_edge_api, source_type: :api) }

  shared_context 'with a successful token request' do
    before do
      response = {
        access_token: '2YotnFZFEjr1zCsicMWpAA',
        token_type: 'Bearer',
        expires_in: 7200,
        refresh_token: 'tGzv3JOkF0XG5Qx2TlKWIA'
      }
      stub_request(:post, 'https://monitoringapi.solaredge.com/v2/oauth2/token')
        .to_return(
          status: 200,
          body: response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end
  end

  shared_context 'with a failed token request' do
    before do
      response = {
        error: 'Error',
        error_description: 'Invalid code'
      }
      stub_request(:post, 'https://monitoringapi.solaredge.com/v2/oauth2/token')
        .to_return(
          status: 400,
          body: response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end
  end

  context 'when a required parameter is missing' do
    before { visit oauth_solar_edge_path }

    it 'displays error page' do
      expect(page).to have_title(I18n.t('oauth.solar_edge.error.title'))
    end
  end

  context 'when school cannot be found' do
    before { visit oauth_solar_edge_path(site_id: 4444, code: 'code', external_id: 99) }

    it 'displays error page' do
      expect(page).to have_title(I18n.t('oauth.solar_edge.error.title'))
      expect(page).to have_text('4444')
      expect(page).to have_text('99')
    end
  end

  context 'when retrieving the access token fails' do
    include_context 'with a failed token request'

    let(:school) { create(:school) }

    before { visit oauth_solar_edge_path(site_id: 4444, code: 'code', external_id: school.id) }

    it 'displays error page' do
      expect(page).to have_title(I18n.t('oauth.solar_edge.error.title'))
    end
  end

  context 'when the site cannot be saved because of validation error' do
    include_context 'with a successful token request'

    let(:installation) { create(:solar_edge_installation, amr_data_feed_config:) }
    let(:school) { create(:school) }

    before { visit oauth_solar_edge_path(site_id: installation.site_id, code: 'code', external_id: school.id) }

    it 'displays error page' do
      expect(page).to have_title(I18n.t('oauth.solar_edge.error.title'))
    end
  end

  context 'when the request is successful' do
    include_context 'with a successful token request'

    context 'when installation exists' do
      let(:installation) { create(:solar_edge_installation, amr_data_feed_config:) }

      before do
        visit oauth_solar_edge_path(site_id: installation.site_id, code: 'code', external_id: installation.school_id)
      end

      it 'displays success page' do
        expect(page).to have_title(I18n.t('oauth.solar_edge.success.title'))
        expect(page).to have_link(I18n.t('oauth.solar_edge.success.view_dashboard'),
                                  href: school_path(installation.school))
      end

      it 'updates the installation' do
        expect(installation.reload).to have_attributes(
          access_token: '2YotnFZFEjr1zCsicMWpAA',
          refresh_token: 'tGzv3JOkF0XG5Qx2TlKWIA'
        )
        expect(SolarEdgeInstallation.first.consent_granted_at.to_date).to eq(Time.zone.today)
        expect(SolarEdgeInstallation.first.access_token_expires_at.to_date).to eq(Time.zone.today)
      end

      it 'sends an email' do
        perform_enqueued_jobs
        email = ActionMailer::Base.deliveries.first
        expect(email.to).to include('operations@energysparks.uk')
        expect(email.subject).to eq(
          "[energy-sparks-unknown] Energy Sparks - SolarEdge Site Connected for #{installation.school.name}"
        )
      end
    end

    context 'when installation does not exist' do
      let(:school) { create(:school) }

      before do
        visit oauth_solar_edge_path(site_id: '4000', code: 'code', external_id: school.id)
      end

      it 'displays success page' do
        expect(page).to have_title(I18n.t('oauth.solar_edge.success.title'))
        expect(page).to have_link(I18n.t('oauth.solar_edge.success.view_dashboard'),
                                  href: school_path(school))
      end

      it 'creates a new installation' do
        expect(SolarEdgeInstallation.first).to have_attributes(
          school: school,
          site_id: '4000',
          access_token: '2YotnFZFEjr1zCsicMWpAA',
          refresh_token: 'tGzv3JOkF0XG5Qx2TlKWIA'
        )
        expect(SolarEdgeInstallation.first.consent_granted_at.to_date).to eq(Time.zone.today)
        expect(SolarEdgeInstallation.first.access_token_expires_at.to_date).to eq(Time.zone.today)
      end
    end
  end
end
