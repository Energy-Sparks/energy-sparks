require 'rails_helper'

module Cads
  describe RealtimePowerConsumptionService do

    let!(:school)              { create(:school) }
    let!(:meter)               { create(:electricity_meter, school: school)}
    let!(:cad)                 { create(:cad, school: school, meter: meter) }
    let(:meter_collection)    { double(:meter_collection).as_null_object }

    let(:analytics_meter)     { double(:meter).as_null_object }
    let(:power_consumption_service)    { double(:power_consumption_service) }

    let(:cache_key)   { "#{cad.school.id}-#{cad.school.name.parameterize}-power-consumption-service-#{cad.id}" }

    context '#cache_power_consumption_service' do
      it 'caches the service' do
        expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 45.minutes)
        RealtimePowerConsumptionService.cache_power_consumption_service(meter_collection, cad)
      end
      it 'uses the right meter' do
        expect(meter_collection).to receive(:meter?).with(meter.mpan_mprn.to_s).and_return(analytics_meter)

        allow(::PowerConsumptionService).to receive(:create_service).with(meter_collection, analytics_meter).and_return(power_consumption_service)

        RealtimePowerConsumptionService.cache_power_consumption_service(meter_collection, cad)
      end

      it 'defaults to aggregated_electricity_meters' do
        cad.update!(meter: nil)

        expect(meter_collection).to receive(:aggregated_electricity_meters).and_return(analytics_meter)

        allow(::PowerConsumptionService).to receive(:create_service).with(meter_collection, analytics_meter).and_return(power_consumption_service)

        RealtimePowerConsumptionService.cache_power_consumption_service(meter_collection, cad)
      end
    end

    context '#read_consumption' do
      let(:power_consumption_service)    { double(:power_consumption_service) }
      before(:each) do
        allow(::PowerConsumptionService).to receive(:create_service).with(meter_collection, analytics_meter).and_return(power_consumption_service)
      end
      it 'calls the service' do
        expect(Rails.cache).to receive(:fetch).with(cache_key).and_return(power_consumption_service)
        expect(power_consumption_service).to receive(:perform).and_return(99)
        expect(RealtimePowerConsumptionService.read_consumption(cad)).to eql 99
      end

      context 'service not in cache' do
        let(:power_consumption_service)    { nil }
        it 'does not error' do
          expect(RealtimePowerConsumptionService.read_consumption(cad)).to be_nil
        end
      end
    end
  end
end
