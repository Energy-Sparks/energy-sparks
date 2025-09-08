# frozen_string_literal: true

require 'rails_helper'

describe ChartToMeterMap do
  subject(:map) { ChartToMeterMap.instance }

  describe '#meter' do
    let(:meter_collection) { build(:meter_collection) }

    let(:solar_pv_meter) { build(:meter, meter_collection: meter_collection, type: :solar_pv) }

    let(:electricity_meter) { build(:meter, :with_flat_rate_tariffs, meter_collection: meter_collection, type: :electricity) }

    let(:electricity_meter_with_solar) do
      solar_attributes = {}
      solar_attributes[:solar_pv_mpan_meter_mapping] = [{
        start_date: Date.new(2023, 1, 1),
        production_mpan: solar_pv_meter.mpan_mprn.to_s
      }]

      # ELECTRICITY WITH SOLAR
      build(:meter,
            :with_flat_rate_tariffs,
            meter_collection: meter_collection,
            type: :electricity,
            meter_attributes: solar_attributes)
    end

    let(:electricity_meter_with_storage_heaters) { build(:meter, :with_storage_heater) }

    let(:gas_meter) do
      build(:meter,
            :with_flat_rate_tariffs,
            meter_collection: meter_collection,
            type: :gas, meter_attributes: {})
    end

    # Build meter collection with electricity, heat, solar, storage heaters
    before do
      meter_collection.add_electricity_meter(solar_pv_meter)
      meter_collection.add_electricity_meter(electricity_meter)
      meter_collection.add_electricity_meter(electricity_meter_with_solar)
      meter_collection.add_electricity_meter(electricity_meter_with_storage_heaters)
      meter_collection.add_heat_meter(gas_meter)
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
      meter_collection
    end

    def expect_not_nil(definition)
      expect(map.meter(meter_collection, definition)).not_to be_nil
    end

    context 'with logical meter names' do
      it 'returns expected meters' do
        expect(map.meter(meter_collection, :all)).to contain_exactly(meter_collection.aggregated_electricity_meters, meter_collection.aggregated_heat_meters)
        # Check returns expected meter
        expect(map.meter(meter_collection, :allheat)).to eq(meter_collection.aggregated_heat_meters)
        expect(map.meter(meter_collection, :allelectricity)).to eq(meter_collection.aggregated_electricity_meters)
        expect(map.meter(meter_collection, :storage_heater_meter)).to eq(meter_collection.storage_heater_meter)
        expect(map.meter(meter_collection, :solar_pv_meter)).to eq(
          meter_collection.aggregated_electricity_meters.sub_meters[:generation]
        )
        # ...but also check those meters aren't nil
        %i[allheat allelectricity storage_heater_meter solar_pv_meter].each do |definition|
          expect_not_nil(definition)
        end
      end

      it 'raises error if unknown meter requested' do
        expect { map.meter(meter_collection, :unknown) }.to raise_error(ChartToMeterMap::UnknownChartMeterDefinition)
      end
    end

    context 'with mpxn' do
      context 'when requesting meters that have not been aggregated' do
        it 'returns expected meters' do
          expect(map.meter(meter_collection, electricity_meter.mpan_mprn)).to eq(electricity_meter)
          expect(map.meter(meter_collection, gas_meter.mpan_mprn)).to eq(gas_meter)
          expect(map.meter(meter_collection, solar_pv_meter.mpan_mprn)).to eq(solar_pv_meter)
        end
      end

      context 'when requesting meters that have been aggregated/disaggregated' do
        # Solar aggregation process creating a new meter with same mpan.
        it 'returns the mains+self consumption meter for the electricity meter mpan with solar' do
          mains_plus_self_consume = map.meter(meter_collection, electricity_meter_with_solar.mpan_mprn)
          expect(mains_plus_self_consume.sub_meters[:mains_consume]).to eq(electricity_meter_with_solar)
        end

        it 'returns the new electricity meter without storage heater usage for the electricity meter with storage heaters mpan' do
          synthetic_mpan = Dashboard::Meter.synthetic_mpan_mprn(electricity_meter_with_storage_heaters.mpan_mprn, :storage_heater_disaggregated_electricity)
          expect_not_nil(synthetic_mpan)
          electricity_without_storage = map.meter(meter_collection, synthetic_mpan)
          expect(electricity_without_storage.sub_meters[:mains_consume]).to eq(electricity_meter_with_storage_heaters)
        end

        # Storage heater aggregation process creates meters with synthetic mpans
        it 'still returns the original electricity meter for the meter with attached storage heaters' do
          meter = map.meter(meter_collection, electricity_meter_with_storage_heaters.mpan_mprn)
          expect(meter).to eq(electricity_meter_with_storage_heaters)
        end
      end

      it 'returns nil for unknown meter' do
        expect(map.meter(meter_collection, '99999')).to be_nil
      end
    end

    context 'with mpxn and sub meter definition' do
      context 'when there are no sub meters' do
        it 'returns nil' do
          expect(map.meter(meter_collection, electricity_meter.mpan_mprn, :generation)).to be_nil
        end
      end

      context 'when there are sub meters' do
        it 'returns the correct solar sub meters' do
          expect(map.meter(meter_collection, electricity_meter_with_solar.mpan_mprn, :mains_consume)).to eq(electricity_meter_with_solar)
          expect(map.meter(meter_collection, electricity_meter_with_solar.mpan_mprn, :generation)).to eq(solar_pv_meter)
          expect(map.meter(meter_collection, electricity_meter_with_solar.mpan_mprn, :export).fuel_type).to eq(:exported_solar_pv)
          expect(map.meter(meter_collection, electricity_meter_with_solar.mpan_mprn, :self_consume).fuel_type).to eq(:solar_pv)
        end

        it 'returns the correct storage heater submeters' do
          synthetic_mpan = Dashboard::Meter.synthetic_mpan_mprn(electricity_meter_with_storage_heaters.mpan_mprn, :storage_heater_disaggregated_electricity)
          expect(map.meter(meter_collection, synthetic_mpan, :mains_consume)).to eq(electricity_meter_with_storage_heaters)
          expect(map.meter(meter_collection, synthetic_mpan, :storage_heaters).fuel_type).to eq(:storage_heater)
        end
      end
    end
  end
end
