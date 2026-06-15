# frozen_string_literal: true

require 'rails_helper'

describe Dashboard::Meter do
  describe '#create' do
    let(:type) { :electricity }
    let(:identifier) { 1_234_567_890 }

    let(:valid_params) do
      {
        meter_collection: [],
        amr_data: nil,
        type: type,
        identifier: identifier,
        name: 'some-meter-name',
        floor_area: nil,
        number_of_pupils: nil,
        solar_pv_installation: nil,
        external_meter_id: nil,
        dcc_meter: true,
        meter_attributes: {}
      }
    end

    describe '#initialize' do
      it 'creates a meter' do
        meter = described_class.new(**valid_params)
        expect(meter.mpan_mprn).to eq(identifier)
        expect(meter.dcc_meter).to be true
      end

      it 'creates a heat meter' do
        %i[gas storage_heater aggregated_heat].each do |type|
          meter = described_class.new(**valid_params.merge({ type: type }))
          expect(meter.heat_meter?).to be true
          expect(meter.electricity_meter?).to be false
        end
      end

      it 'creates an electricity meter' do
        %i[electricity solar_pv aggregated_electricity].each do |type|
          meter = described_class.new(**valid_params.merge({ type: type }))
          expect(meter.heat_meter?).to be false
          expect(meter.electricity_meter?).to be true
        end
      end
    end

    describe '#inspect' do
      let(:meter) { described_class.new(**valid_params.merge({ type: type })) }

      it 'works as expected' do
        expect(meter.inspect).to include(identifier.to_s)
        expect(meter.inspect).to include(type.to_s)
      end
    end

    describe '#analytics_name' do
      let(:identifier)  { '1456789' }
      let(:name)        { nil }

      let(:meter) { build(:meter, identifier: identifier, name: name) }

      it 'returns mpxn by default' do
        expect(meter.analytics_name).to eq(identifier)
      end

      context 'with name' do
        let(:name)  { 'Kitchen' }

        it 'returns bracketed text' do
          expect(meter.analytics_name).to eq('Kitchen (1456789)')
        end
      end
    end

    describe '.aggregate_pseudo_meter_attribute_key' do
      {
        storage_heater: :storage_heater_aggregated,
        solar_pv: :solar_pv_consumed_sub_meter,
        exported_solar_pv: :solar_pv_exported_sub_meter,
        electricity: :aggregated_electricity,
        gas: :aggregated_gas
      }.each do |fuel_type, key|
        it "returns #{key} for #{fuel_type}" do
          expect(described_class.aggregate_pseudo_meter_attribute_key(fuel_type)).to eq(key)
        end
      end
    end

    # TODO: check on fuel type not currently applied
    # it "raises error for unknown fuel type" do
    #   expect {
    #     Dashboard::Meter.new(valid_params.merge({type: :fruit}))
    #   }.to raise_error(EnergySparksUnexpectedStateException.new("Unexpected fuel type fruit"))
    # end
  end

  describe '.synthetic_combined_meter_mpan_mprn_from_urn' do
    {
      ['9206222810', :electricity] => 90_009_206_222_810,
      ['9206222810', :aggregated_electricity] => 90_009_206_222_810,
      ['9206222810', :gas] => 80_009_206_222_810,
      ['9206222810', :aggregated_heat] => 80_009_206_222_810,
      ['9206222810', :storage_heater] => 70_009_206_222_810,
      ['9206222810', :solar_pv] => 70_009_206_222_810,
      ['9206222810', :solar_pv, 1] => 71_009_206_222_810,
      ['9206222810', :exported_solar_pv] => 60_009_206_222_810,
      ['9206222810', :exported_solar_pv, 1] => 61_009_206_222_810
    }.each do |args, expected|
      it "expected #{args[1]} to eq #{expected}" do
        expect(described_class.synthetic_combined_meter_mpan_mprn_from_urn(*args)).to eq(expected)
      end
    end
  end

  describe '.synthetic_mpan_mprn' do
    {
      ['2200012581130', :storage_heater_only] => 72_200_012_581_130,
      ['2200012581130', :storage_heater_disaggregated_storage_heater] => 72_200_012_581_130,
      ['2200012581130', :storage_heater_disaggregated_electricity] => 77_200_012_581_130,
      ['2200012581130', :electricity_minus_storage_heater] => 77_200_012_581_130,
      ['2200012581130', :solar_pv] => 82_200_012_581_130,
      ['2319047458', :solar_pv] => 80_002_319_047_458
    }.each do |args, expected|
      it "expects #{args[1]} to eq #{expected}" do
        expect(described_class.synthetic_mpan_mprn(*args)).to eq(expected)
      end
    end
  end

  describe '.synthetic_aggregate_generation_meter' do
    {
      ['2200012581130'] => 22_200_012_581_130,
      ['2319047458'] => 20_002_319_047_458
    }.each do |args, expected|
      it "expects #{args[1]} to eq #{expected}" do
        expect(described_class.synthetic_aggregate_generation_meter(*args)).to eq(expected)
      end
    end
  end
end
