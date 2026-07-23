# frozen_string_literal: true

require 'rails_helper'

describe 'MeterZ installation management' do
  it_behaves_like 'solar installation management' do
    let(:installation_type) { 'MeterZ' }
    let(:installation_model) { MeterZInstallation }
    let(:loader_job) { Solar::MeterZLoaderJob }
    let(:installation) do
      create(:solar_pv_meter, school:, meter_z_installation: create(:meter_z_installation)).meter_z_installation
    end

    def stub_successful_verify
      stub_request(:get, 'https://api.meterz.co.uk/v1/organisations')
        .to_return(headers: { 'content-type': 'application/json' },
                   body: { organisations: [{ organisation_id: :id }] }.to_json)
      stub_request(:get, 'https://api.meterz.co.uk/v1/organisations/id/meters')
        .to_return(headers: { 'content-type': 'application/json' },
                   body: { meters: meters_list }.to_json)
    end

    def stub_unsuccessful_verify
      stub_request(:get, 'https://api.meterz.co.uk/v1/organisations').to_return(status: 403)
    end

    def meters_list = [{ meter_name: 'meter name', site_name: 'site name', meter_id: '123' }.stringify_keys]

    def create_new_installation = fill_in('API Key', with: 'api_key')

    def check_installation
      expect(MeterZInstallation.last).to have_attributes(api_key: 'api_key', active: false, meters_list:)
    end

    def installation_key = installation.api_key

    def edit = fill_in(:meter_z_installation_api_key, with: 'newkey')

    def check_edit
      expect(page).to have_text('newkey')
      expect(MeterZInstallation.last.api_key).to eq('newkey')
    end
  end
end
