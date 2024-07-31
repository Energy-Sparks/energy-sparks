require 'rails_helper'

describe Meters::N3rgyMeteringService, type: :service do
  subject(:service) { described_class.new(meter) }

  let(:meter) { create(:electricity_meter, dcc_meter: :smets2, consent_granted: true) }

  describe '#available_data' do
    let(:stub) { instance_double('data-api-client') }

    before do
      allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(stub)
    end

    context 'with an api response' do
      before do
        allow(stub).to receive(:consumption).and_return(response)
      end

      context 'when the response was successful' do
        let(:response) { JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-consumption.json')) }

        it 'returns an array of results' do
          dates = service.available_data
          expect(dates.first).to eq(DateTime.parse('201204270900'))
          expect(dates.last).to eq(DateTime.parse('201402280000'))
        end
      end

      context 'when the response was for a meter thats not reading properly' do
        let(:response) do
          {
            'responseTimestamp' => '2024-02-23T11:17:01.055Z'
          }
        end

        it 'returns an empty array of results' do
          expect(service.available_data).to eq([])
        end
      end
    end

    context 'with an api error' do
      before do
        allow(stub).to receive(:consumption).and_raise
      end

      it 'returns an empty array' do
        expect(service.available_data).to eq([])
      end
    end
  end

  describe '#status' do
    let(:stub) { stub_request(:get, %r{^https://n3rgy.test/find-mpxn/}) }

    it 'returns available' do
      stub.to_return(body: '{}')
      expect(service.status).to eq(:available)
    end

    it 'handles not found' do
      stub.to_return(status: 404)
      expect(service.status).to eq(:unknown)
    end

    it 'handles not allowed' do
      stub.to_return(status: 403)
      expect(service.status).to eq(:consent_required)
    end
  end

  describe '#type' do
    let(:stub) { stub_request(:get, %r{^https://n3rgy.test/find-mpxn/}) }

    it 'returns smets2' do
      stub.to_return(body: '{"deviceId": "01-0A-00-00-00-00-FF-03"}')
      expect(service.type).to eq(:smets2)
    end

    it 'returns other' do
      stub.to_return(body: '{}')
      expect(service.type).to eq(:other)
    end

    it 'returns no' do
      stub.to_return(status: 404)
      expect(service.type).to eq(:no)
    end

    it 'caches' do
      stub.to_return(status: 404)
      service = described_class.new(meter, cache: true)
      service.type
      service.type
      expect(stub).to have_been_requested.times(1)
    end
  end
end
