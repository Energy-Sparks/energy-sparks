# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::LowCarbonHubMeterReadings do
  subject(:service) { described_class.new }

  around do |example|
    ClimateControl.modify ENERGYSPARKSRBEEUSERNAME: 'username', ENERGYSPARKSRBEEPASSWORD: 'password' do
      example.run
    end
  end

  describe '#download' do
    subject(:response) { service.download('218854673', '6802318', Date.new(2026, 7, 4), Date.new(2026, 7, 9)) }

    let(:stub) do
      stub_request(:any, %r{pvmeter\.com/solar/webservices/getDeviceSmartData}).to_return(
        status: 200,
        body: File.read('spec/fixtures/rbee/get_device_smart_data.json'),
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    before do
      travel_to(DateTime.new(2026, 7, 10, 10, 0))
      stub
      response
    end

    it 'calls the relevant API' do
      expect(stub).to have_been_requested
      request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys[0]
      expect(request.uri.query_values).to include(
        'login' => 'username',
        'serialNumber' => '218854673',
        'startDate' => (Date.new(2026, 7, 4) - 1.hour).strftime('%Y-%m-%dT%H:%M:%S'),
        'endDate' => (Date.new(2026, 7, 9) + 1.day).midnight.strftime('%Y-%m-%dT%H:%M:%S'),
        'step' => 'tenmin'
      )
    end

    it 'returns expected data' do
      expect(response.transform_values { |h| h.slice(:mpan_mprn) }).to eq(
        {
          solar_pv: { mpan_mprn: 70_000_006_802_318 },
          electricity: { mpan_mprn: 90_000_006_802_318 },
          exported_solar_pv: { mpan_mprn: 60_000_006_802_318 }
        }
      )
      %i[solar_pv electricity exported_solar_pv].each do |type|
        expect(response[type][:readings].length).to eq(6)
      end
    end
  end
end
