# frozen_string_literal: true

require 'rails_helper'

describe AggregateDataServiceSolar do
  subject(:processed_meters) { described_class.new(meter_collection).process_solar_pv_electricity_meters }

  let(:sub_meters) { processed_meters.first.sub_meters }
  let(:meter_collection) { build(:meter_collection, random_generator: Random.new(51)) }
  let(:solar_pv_mpan_meter_mapping) { nil }
  let(:meter_attributes) do
    { solar_pv_mpan_meter_mapping: ([solar_pv_mpan_meter_mapping] unless solar_pv_mpan_meter_mapping.nil?) }.compact
  end
  let(:electricity_meter) do
    build(:meter, meter_collection:, type: :electricity, meter_attributes:, kwh_data_x48: Array.new(48, 2))
  end
  let(:solar_production_meter) { nil }
  let(:solar_export_meter) { nil }
  let(:meters) { [electricity_meter, solar_production_meter, solar_export_meter].compact }

  before do
    travel_to Date.new(2025, 5, 31)
    meters.each { |meter| meter_collection.add_electricity_meter(meter) }
  end

  context 'when school does not have solar' do
    it 'returns the existing electricity meter' do
      expect(processed_meters).to eq([electricity_meter])
      # adds itself as a mains consumption meter
      expect(electricity_meter.sub_meters[:mains_consume]).to eq(electricity_meter)
    end
  end

  context 'when school does not have metered solar' do
    let(:meter_attributes) do
      { solar_pv: [{ start_date: Date.new(2023, 1, 1), kwp: 10.0 }] }
    end

    it 'returns a single new electricity meter' do
      expect(processed_meters.length).to eq(1)
      expect(processed_meters.first.mpan_mprn).to eq(electricity_meter.mpan_mprn)
      expect(processed_meters.first.meter_type).to eq(:electricity)
    end

    it 'configures the electricity meter as a sub meter' do
      expect(sub_meters[:mains_consume]).to eq(electricity_meter)
    end

    it 'creates new generation, self consumption and export meters' do
      expect(sub_meters[:generation]).not_to be_nil
      expect(sub_meters[:self_consume]).not_to be_nil
      expect(sub_meters[:export]).not_to be_nil
    end
  end

  context 'when school has metered solar' do
    let(:solar_production_meter) { build(:meter, meter_collection: meter_collection, type: :solar_pv) }
    let(:solar_pv_mpan_meter_mapping) do
      {
        start_date: Date.new(2023, 1, 1),
        production_mpan: solar_production_meter.mpan_mprn.to_s,
        export_mpan: solar_export_meter&.mpan_mprn&.to_s
      }.compact
    end

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
        expect(sub_meters[:export].amr_data.values.map(&:one_day_kwh)).to eq(Array.new(30, 0))
      end
    end

    context 'with production and export meters' do
      let(:solar_production_meter) do
        build(:meter, meter_collection: meter_collection, type: :solar_pv, kwh_data_x48: Array.new(48, 4))
      end
      let(:solar_export_meter) do
        build(:meter, meter_collection: meter_collection, type: :exported_solar_pv, kwh_data_x48: Array.new(48, 1))
      end

      it 'returns a single new electricity meter' do
        expect(processed_meters.length).to eq(1)
        expect(processed_meters.first.mpan_mprn).to eq(electricity_meter.mpan_mprn)
        expect(processed_meters.first.meter_type).to eq(:electricity)
      end

      it 'configures the electricity, export and production meters as sub meters' do
        expect(sub_meters[:mains_consume]).to eq(electricity_meter)
        expect(sub_meters[:generation]).to eq(solar_production_meter)
        expect(sub_meters[:export]).to eq(solar_export_meter)
      end

      it 'creates a new self consumption meter' do
        expect(sub_meters[:self_consume]).not_to be_nil
      end

      context 'with faulty zero production' do
        let(:solar_production_meter) do
          build(:meter, meter_collection: meter_collection, type: :solar_pv,
                        amr_data: build(:amr_data, :with_days, day_count: 30, kwh_data_x48: Array.new(48, 0.0)))
        end

        it 'zeros negative data' do
          reading = processed_meters.first.sub_meters[:self_consume].amr_data.values.first
          expect(reading.kwh_data_x48).to eq(Array.new(48, 0.0))
        end
      end

      context 'with export override' do
        let(:meter_attributes) do
          super().merge({ solar_pv_override: [{ start_date: Date.new(2023, 1, 1), kwp: 10.0, override_export: true }] })
        end

        it 'overrides the export' do
          # debugger
          expect(sub_meters[:export].amr_data[Date.new(2025, 5, 9)]).to have_attributes(type: 'SOLE', one_day_kwh: 0)
          expect(sub_meters[:export].amr_data[Date.new(2025, 5, 10)]).to have_attributes(type: 'SOLE', one_day_kwh: -96)
        end

        it 'modifies export only' do
          expect(sub_meters[:generation].amr_data[Date.new(2025, 5, 3)].type).to eq('ORIG')
        end
      end

      context 'with generation and export override' do
        let(:meter_attributes) do
          super().merge({ solar_pv_override: [{ start_date: Date.new(2023, 1, 1), kwp: 10.0, override_generation: true,
                                                override_export: true }] })
        end

        it 'overrides export' do
          expect(sub_meters[:export].amr_data[Date.new(2025, 5, 26)]).to have_attributes(type: 'SOLE', one_day_kwh: 0.0)
          expect(sub_meters[:export].amr_data[Date.new(2025, 5, 27)]).to \
            have_attributes(type: 'SOLE', one_day_kwh: be_within(0.01).of(-28.42))
          expect(sub_meters[:generation].amr_data[Date.new(2025, 5, 26)]).to \
            have_attributes(type: 'SOLR', one_day_kwh: be_within(0.01).of(97.67))
        end
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
        expect(sub_meters[:generation].mpan_mprn).to \
          eq(Dashboard::Meter.synthetic_aggregate_generation_meter(solar_production_meters.first.mpan_mprn))
      end
    end
  end
end
