require 'rails_helper'

describe Meters::N3rgyMeteringService, type: :service do
  subject(:service) do
    described_class.new(meter)
  end

  let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true) }

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
end
