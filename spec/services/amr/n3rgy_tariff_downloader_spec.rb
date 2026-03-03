require 'rails_helper'

describe Amr::N3rgyTariffDownloader, type: :service do
  subject(:service) do
    described_class.new(meter: meter)
  end

  let(:meter)     { create(:electricity_meter) }
  let(:config)    { create(:amr_data_feed_config) }

  let(:stub) { instance_double(DataFeeds::N3rgy::DataApiClient) }

  before do
    allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(stub)
    allow(stub).to receive(:tariff).with(meter.mpan_mprn, meter.meter_type).and_return(response.with_indifferent_access)
  end

  context 'with an unexpected response format' do
    let(:response) do
      {
        devices: []
      }
    end

    it 'returns nothing' do
      expect(service.current_tariff).to be_nil
    end

    it 'raises error via Rollbar' do
      expect(Rollbar).to receive(:error).with(anything, meter: meter.mpan_mprn, school: meter.school.name)
      service.current_tariff
    end
  end

  context 'with missing tariffs on meter' do
    let(:response) do
      {
        devices: [
          {
            deviceId: '1-2-3-4',
            tariffs: [
              {
                firstReading: '20231114005424',
                lastReading: '20240227010457',
                primaryActiveTariffPrice: 0,
                currencyUnitsName: 'Millipence',
                currencyUnitsLabel: 'GB Pounds',
                standingCharge: 0
              }
            ],
            months: []
          }
        ]
      }
    end

    it 'returns nothing' do
      expect(service.current_tariff).to be_nil
    end
  end

  context 'with flat rate tariffs' do
    let(:response) { JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-tariff.json')) }

    it 'parses the standing charge' do
      expect(service.current_tariff[:standing_charge]).to be_within(0.00001).of(1.25246)
    end

    it 'parses the flat rate' do
      expect(service.current_tariff[:flat_rate]).to be_within(0.00001).of(0.05648)
    end
  end

  context 'with unsupported tariffs' do
    let(:response) do
      {
        devices: [
          {
            deviceId: '1-2-3-4',
            tariffs: [
              {
                primaryActiveTariffPrice: 123,
                standingCharge: 2
              }
            ],
            months: [
              {
                days: [{
                  timePeriods: [{
                    start: '00:00',
                    end: '23:59',
                    prices: [
                      { type: 'Block',
                        limit: '10.000',
                        value: 0.0 }
                    ]
                  }]
                }]
              }
            ]
          }
        ]
      }
    end

    it 'returns nothing' do
      expect(service.current_tariff).to be_nil
    end

    it 'warns via Rollbar' do
      expect(Rollbar).to receive(:warning).with(anything, meter: meter.mpan_mprn, school: meter.school.name)
      service.current_tariff
    end
  end

  context 'with differential tariffs' do
    let(:response) do
      {
        devices: [
          {
            deviceId: '1-2-3-4',
            tariffs: [
              {
                primaryActiveTariffPrice: 123,
                standingCharge: 125.246
              }
            ],
            months: [
              {
                days: [{
                  timePeriods: [{
                    start: '00:00',
                    end: '07:00',
                    prices: [
                      { type: 'TOU',
                        value: 5.0 }
                    ]
                  }, {
                    start: '07:00',
                    end: '23:59',
                    prices: [
                      { type: 'TOU',
                        value: 10.0 }
                    ]
                  }]
                }]
              }
            ]
          }
        ]
      }
    end

    it 'parses the standing charge' do
      expect(service.current_tariff[:standing_charge]).to be_within(0.00001).of(1.25246)
    end

    it 'parses the time periods' do
      differential_prices = service.current_tariff[:differential]
      expect(differential_prices).not_to be_nil
      expect(differential_prices).to contain_exactly({
                                                       start_time: '00:00',
                                                       end_time: '07:00',
                                                       value: 0.05,
                                                       units: 'kwh'
                                                     }, {
                                                       start_time: '07:00',
                                                       end_time: '00:00',
                                                       value: 0.1,
                                                       units: 'kwh'
                                                     })
    end
  end
end
