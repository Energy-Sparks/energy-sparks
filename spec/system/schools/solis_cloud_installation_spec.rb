# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

describe 'SolisCloud installation management' do
  it_behaves_like 'solar installation management' do
    let(:installation_type) { 'SolisCloud' }
    let(:installation_model) { SolisCloudInstallation }
    let(:loader_job) { Solar::SolisCloudLoaderJob }
    let(:installation) do
      installation = create(:solis_cloud_installation, inverter_detail_list: [{ sn: '123' }])
      installation.schools << school
      installation
    end

    def stub_successful_verify
      stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList')
        .to_return(headers: { 'content-type': 'application/json' },
                   body: { data: { records: [{}] } }.to_json)
    end

    def stub_unsuccessful_verify
      stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/inverterDetailList').to_return(status: 403)
    end

    def create_new_installation
      fill_in('API ID', with: 'api_id')
      fill_in('API Secret', with: 'api_secret')
    end

    def check_installation
      expect(SolisCloudInstallation.last).to have_attributes(api_id: 'api_id', api_secret: 'api_secret', active: false)
    end

    def installation_key = installation.api_id

    def edit = fill_in(:solis_cloud_installation_api_id, with: 'new_id')

    def check_edit
      expect(page).to have_text('new_id')
      expect(SolisCloudInstallation.last.api_id).to eq('new_id')
    end

    context 'with an existing installation' do
      before do
        installation.update!(inverter_detail_list: [{ sn: '1234', stationName: school.name }])
        visit school_solar_feeds_configuration_index_path(school)
      end

      it 'allows creating a meter with school as station name' do
        click_on('Edit')
        click_on('Assign')
        expect(installation.meters.pluck(:meter_serial_number)).to eq(['1234'])
        expect(installation.meters.first.name).to include(school.name)
      end
    end
  end
end
