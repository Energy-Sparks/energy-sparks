# frozen_string_literal: true

require 'spec_helper'

describe AggregateDataServiceSolar do
  subject(:processed_meters) { described_class.new(meter_collection).process_solar_pv_electricity_meters }

  let(:meter_collection) do
    build(:meter_collection)
  end

  let(:electricity_meter) do
    build(:meter,
          meter_collection: meter_collection,
          type: :electricity, meter_attributes: meter_attributes)
  end

  let(:meters) { [electricity_meter] }

  before do
    meters.each do |meter|
      meter_collection.add_electricity_meter(meter)
    end
  end

  context 'when school does not have solar' do
    let(:meter_attributes) { {} }

    it 'returns the existing electricity meter' do
      expect(processed_meters).to eq([electricity_meter])
      # adds itself as a mains consumption meter
      expect(electricity_meter.sub_meters[:mains_consume]).to eq(electricity_meter)
    end
  end

  context 'when school does not have metered solar' do
    let(:meter_attributes) do
      {
        solar_pv: [{ start_date: Date.new(2023, 1, 1), kwp: 10.0 }]
      }
    end

    it 'returns a single new electricity meter' do
      expect(processed_meters.length).to eq(1)
      expect(processed_meters.first.mpan_mprn).to eq(electricity_meter.mpan_mprn)
      expect(processed_meters.first.meter_type).to eq(:electricity)
    end

    it 'configures the electricity meter as a sub meter' do
      sub_meters = processed_meters.first.sub_meters
      expect(sub_meters[:mains_consume]).to eq(electricity_meter)
    end

    it 'creates new generation, self consumption and export meters' do
      sub_meters = processed_meters.first.sub_meters
      expect(sub_meters[:generation]).not_to be_nil
      expect(sub_meters[:self_consume]).not_to be_nil
      expect(sub_meters[:export]).not_to be_nil
    end
  end

  context 'when school has metered solar' do
    let(:meter_attributes) do
      {
        solar_pv_mpan_meter_mapping: [solar_pv_mpan_meter_mapping]
      }
    end

    let(:solar_production_meter) { build(:meter, meter_collection: meter_collection, type: :solar_pv) }
    let(:solar_pv_mpan_meter_mapping) do
      {
        start_date: Date.new(2023, 1, 1),
        production_mpan: solar_production_meter.mpan_mprn.to_s
      }
    end

    let(:meters) { [electricity_meter, solar_production_meter] }

    context 'with only production meter' do
      it 'returns a single new electricity meter' do
        expect(processed_meters.length).to eq(1)
        expect(processed_meters.first.mpan_mprn).to eq(electricity_meter.mpan_mprn)
        expect(processed_meters.first.meter_type).to eq(:electricity)
      end

      it 'configures the electricity and production meters as sub meters' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:mains_consume]).to eq(electricity_meter)
        expect(sub_meters[:generation]).to eq(solar_production_meter)
      end

      it 'creates new self consumption and export meters' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:self_consume]).not_to be_nil
        expect(sub_meters[:export]).not_to be_nil
      end
    end

    context 'with production and export meters' do
      let(:solar_export_meter) { build(:meter, meter_collection: meter_collection, type: :exported_solar_pv) }
      let(:solar_pv_mpan_meter_mapping) do
        {
          start_date: Date.new(2023, 1, 1),
          export_mpan: solar_export_meter.mpan_mprn.to_s,
          production_mpan: solar_production_meter.mpan_mprn.to_s
        }
      end
      let(:meters) { [electricity_meter, solar_production_meter, solar_export_meter] }

      it 'returns a single new electricity meter' do
        expect(processed_meters.length).to eq(1)
        expect(processed_meters.first.mpan_mprn).to eq(electricity_meter.mpan_mprn)
        expect(processed_meters.first.meter_type).to eq(:electricity)
      end

      it 'configures the electricity, export and production meters as sub meters' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:mains_consume]).to eq(electricity_meter)
        expect(sub_meters[:generation]).to eq(solar_production_meter)
        expect(sub_meters[:export]).to eq(solar_export_meter)
      end

      it 'creates a new self consumption meter' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:self_consume]).not_to be_nil
      end
    end

    context 'with multiple production meters and no export meter' do
      let(:solar_production_meters) { build_list(:meter, 5, meter_collection: meter_collection, type: :solar_pv) }
      let(:solar_pv_mpan_meter_mapping) do
        {
          start_date: Date.new(2023, 1, 1),
          production_mpan: solar_production_meters[0].mpan_mprn.to_s,
          production_mpan2: solar_production_meters[1].mpan_mprn.to_s,
          production_mpan3: solar_production_meters[2].mpan_mprn.to_s,
          production_mpan4: solar_production_meters[3].mpan_mprn.to_s,
          production_mpan5: solar_production_meters[4].mpan_mprn.to_s
        }
      end
      let(:meters) { solar_production_meters + [electricity_meter] }

      it 'returns a single new electricity meter' do
        expect(processed_meters.length).to eq(1)
        expect(processed_meters.first.mpan_mprn).to eq(electricity_meter.mpan_mprn)
        expect(processed_meters.first.meter_type).to eq(:electricity)
      end

      it 'configures the electricity meter as a sub meter' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:mains_consume]).to eq(electricity_meter)
      end

      it 'creates new self consumption and export meters' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:self_consume]).not_to be_nil
        expect(sub_meters[:export]).not_to be_nil
      end

      it 'creates a new generation meter from the 5 actual meters' do
        sub_meters = processed_meters.first.sub_meters

        # process creates a new generation meter out of those provided
        expect(solar_production_meters).not_to include(sub_meters[:generation])

        # uses mpan_mprn of first generation meter
        expect(sub_meters[:generation].mpan_mprn).to eq(Dashboard::Meter.synthetic_aggregate_generation_meter(solar_production_meters.first.mpan_mprn))
      end
    end
  end
end
