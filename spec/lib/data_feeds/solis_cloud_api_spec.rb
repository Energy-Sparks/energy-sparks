# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::SolisCloudApi do
  describe '#user_station_list' do
    it 'calls the relevant API' do
      travel_to(Date.new(2025, 1, 8))
      stub = stub_request(:post, 'https://www.soliscloud.com:13333/v1/api/userStationList')
      described_class.new('id', 'secret').user_station_list
      expect(stub).to have_been_requested
      request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys[0]
      expect(request.headers).to include(
        'content-type' => 'application/json',
        'content-md5' => 'mZFLkyvTelC5g8XnyQrpOw==',
        'date' => 'Wed, 08 Jan 2025 00:00:00 GMT',
        'authorization' => 'API id:zVR1YsbUTOitFBhUEbAjpCBAo9I='
      )
    end
  end
end
