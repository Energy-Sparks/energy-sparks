# frozen_string_literal: true

require 'rails_helper'

describe AggregateDataServiceSolar do
  subject(:processed_meters) { described_class.new(meter_collection).process_solar_pv_electricity_meters }

  let(:meter_collection) { build(:meter_collection, random_generator: Random.new(51), end_date: Date.current) }
  let(:meter_attributes) { {} }
  let(:solar_production_meter) { nil }
  let(:solar_export_meter) { nil }
  let(:meters) do
    { electricity: build(:meter, meter_collection:, type: :electricity, meter_attributes:,
                                 kwh_data_x48: Array.new(48, 2), day_count: 8),
      solar_production: solar_production_meter,
      solar_export: solar_export_meter }
  end

  def sub_meters = processed_meters.first.sub_meters
  def electricity_meter = meters[:electricity]
  def meters_values = meters.values.flatten.compact

  before do
    travel_to Date.new(2025, 5, 28)
    meters_values.each { |meter| meter_collection.add_electricity_meter(meter) }
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
    let(:solar_production_meter) { build(:meter, meter_collection:, type: :solar_pv, kwh_data_x48: [1] * 48) }
    let(:meter_attributes) do
      { solar_pv_mpan_meter_mapping: [{ start_date: Date.new(2023, 1, 1),
                                        production_mpan: solar_production_meter.mpan_mprn.to_s,
                                        export_mpan: solar_export_meter&.mpan_mprn&.to_s }] }
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
        expect(sub_meters[:export].amr_data.values.map(&:one_day_kwh)).to eq(Array.new(8, 0))
      end
    end

    context 'with production and export meters' do
      let(:solar_production_meter) do
        build(:meter, meter_collection:, type: :solar_pv, kwh_data_x48: Array.new(48, 4))
      end
      let(:solar_export_meter) do
        build(:meter, meter_collection:, type: :exported_solar_pv, kwh_data_x48: Array.new(48, 1))
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
          build(:meter, meter_collection:, type: :solar_pv,
                        amr_data: build(:amr_data, :with_days, day_count: 30, kwh_data_x48: Array.new(48, 0.0)))
        end

        it 'zeros negative data' do
          reading = processed_meters.first.sub_meters[:self_consume].amr_data.values.first
          expect(reading.kwh_data_x48).to eq(Array.new(48, 0.0))
        end
      end

      context 'with export override' do
        let(:meter_attributes) do
          super().merge({ solar_pv_override: [{ start_date: Date.new(2023), kwp: 10.0, override_export: true }] })
        end

        it 'overrides the export' do
          expect(sub_meters[:export].amr_data.values.map { |reading| [reading.type, reading.one_day_kwh] }).to \
            eq(['SOLE'].product([-96, -96, 0, -96, -96, 0, 0, 0]))
        end

        it 'modifies export only' do
          expect(sub_meters[:generation].amr_data.values.map { |reading| [reading.type, reading.one_day_kwh] }).to \
            eq([['ORIG', 192]] * 8)
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
      let(:solar_production_meter) { build_list(:meter, 5, meter_collection:, type: :solar_pv) }
      let(:meter_attributes) do
        { solar_pv_mpan_meter_mapping: [{ start_date: Date.new(2023, 1, 1),
                                          production_mpan: solar_production_meter[0].mpan_mprn.to_s,
                                          production_mpan2: solar_production_meter[1].mpan_mprn.to_s,
                                          production_mpan3: solar_production_meter[2].mpan_mprn.to_s,
                                          production_mpan4: solar_production_meter[3].mpan_mprn.to_s,
                                          production_mpan5: solar_production_meter[4].mpan_mprn.to_s }] }
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

      it 'creates new self consumption and export meters' do
        sub_meters = processed_meters.first.sub_meters
        expect(sub_meters[:self_consume]).not_to be_nil
        expect(sub_meters[:export]).not_to be_nil
      end

      context 'with a commissioned date' do
        let(:solar_production_meter) { build_list(:meter, 5, meter_collection:, type: :solar_pv, day_count: 4) }
        let(:meter_attributes) do
          super().tap do |attributes|
            attributes[:solar_pv_mpan_meter_mapping].first.merge!(commissioned_date: Date.new(2025, 5, 23))
          end
        end

        it 'backfills all five production meters before combining their readings' do
          generation = sub_meters[:generation]
          solar_production_meter.each do |meter|
            expect(meter.amr_data[Date.new(2025, 5, 23)]).to \
              have_attributes(type: 'SOLC', substitute_date: Date.new(2025, 5, 25),
                              kwh_data_x48: meter.amr_data[Date.new(2025, 5, 25)].kwh_data_x48)
          end
          expect(generation.amr_data[Date.new(2025, 5, 23)].one_day_kwh).to \
            eq(generation.amr_data[Date.new(2025, 5, 25)].one_day_kwh)
        end
      end

      it 'creates a new generation meter from the 5 actual meters' do
        sub_meters = processed_meters.first.sub_meters

        # process creates a new generation meter out of those provided
        expect(solar_production_meter).not_to include(sub_meters[:generation])

        # uses mpan_mprn of first generation meter
        expect(sub_meters[:generation].mpan_mprn).to \
          eq(Dashboard::Meter.synthetic_aggregate_generation_meter(solar_production_meter.first.mpan_mprn))
      end
    end

    context 'and modelled solar' do
      context 'when metered solar starts later' do
        let(:solar_production_meter) do
          build(:meter, meter_collection:, type: :solar_pv, kwh_data_x48: [1] * 48, day_count: 4)
        end
        let(:meter_attributes) do
          super().merge(modelled_solar_pv_generation: [{ start_date: 5.days.ago.to_date, kwp: 1 }])
        end

        it 'generation meter has modelled added' do
          expect(sub_meters[:generation].amr_data.values.map { |value| value.one_day_kwh.round }).to \
            eq([0, 0, 10, 10, 58, 58, 58, 58])
        end
      end

      context 'when modelled solar starts later' do
        let(:meter_attributes) do
          super().merge(modelled_solar_pv_generation: [{ start_date: 3.days.ago.to_date, kwp: 1 }])
        end

        it 'generation meter has modelled added' do
          expect(sub_meters[:generation].amr_data.values.map { |value| value.one_day_kwh.round }).to \
            eq([48, 48, 48, 48, 58, 58, 58, 58])
        end
      end

      context 'with multiple modelled ranges' do
        let(:meter_attributes) do
          super().merge(modelled_solar_pv_generation: [{ start_date: 5.days.ago.to_date, kwp: 1 },
                                                       { start_date: 1.day.ago.to_date, kwp: 2 }])
        end

        it 'generation meter has modelled added' do
          expect(sub_meters[:generation].amr_data.values.map { |value| value.one_day_kwh.round }).to \
            eq([48, 48, 58, 58, 58, 58, 78, 78])
        end
      end
    end

    context 'with a commissioned date' do
      let(:commissioned_date) { Date.new(2026, 5, 2) }
      let(:start_date) { Date.new(2026, 6, 1) }
      let(:end_date) { Date.new(2026, 6, 30) }
      let(:meter_attributes) do
        super().tap { |attributes| attributes[:solar_pv_mpan_meter_mapping].first.merge!(commissioned_date:) }
      end
      let(:meters) do
        amr_data = build(:amr_data, :with_date_range, start_date: commissioned_date - 1.day, end_date:)
        electricity = build(:meter, meter_collection:, type: :electricity, meter_attributes:, amr_data:)
        super().merge(electricity:)
      end
      let(:solar_production_meter) do
        build(:meter, meter_collection:, type: :solar_pv,
                      amr_data: build(:amr_data, :with_date_range, start_date:, end_date:))
      end
      let(:solar_export_meter) do
        build(:meter, meter_collection:, type: :exported_solar_pv,
                      amr_data: build(:amr_data, :with_date_range, start_date: start_date - 1.week, end_date:))
      end
      let(:original_reading_dates) { meters_values.index_with { |meter| meter.amr_data.keys.sort } }

      def group_ranges_by_type(meter)
        grouped = meter.amr_data.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(date, data), hash|
          hash[data.type.to_sym] << date
        end

        grouped.transform_values { |dates| contiguous_date_ranges(dates) }
      end

      def contiguous_date_ranges(dates)
        ranges = dates.sort.chunk_while { |prev, curr| curr == prev + 1.day }
                      .map { |run| run.first..run.last }
        ranges.one? ? ranges.first : ranges
      end

      def expected_ranges_by_type(meter, zero_type: :BKPV)
        { ORIG: original_reading_dates[meter].first..end_date,
          SOLC: commissioned_date..original_reading_dates[meter].first.prev_day,
          zero_type =>
            original_reading_dates[electricity_meter].first..original_reading_dates[electricity_meter].first }
      end

      before do
        original_reading_dates
        processed_meters
      end

      it 'copies each meter’s initial readings', :aggregate_failures do
        expect(group_ranges_by_type(solar_production_meter)).to eq(expected_ranges_by_type(solar_production_meter))
        expect(group_ranges_by_type(solar_export_meter)).to eq(expected_ranges_by_type(solar_export_meter))

        original_reading_dates.to_a[1..].each do |meter, dates|
          days_to_copy = (dates.first - commissioned_date).to_i
          days_to_copy.times do |index|
            source = meter.amr_data[dates[index]]
            duplicate = meter.amr_data[commissioned_date + index]
            expect(duplicate).to have_attributes(type: 'SOLC', substitute_date: source.date,
                                                 date: commissioned_date + index, kwh_data_x48: source.kwh_data_x48)
            expect(duplicate.kwh_data_x48).not_to equal(source.kwh_data_x48)
          end
          expect(meter.amr_data[dates.first].type).to eq('ORIG')
          expect(meter.amr_data[commissioned_date - 1]).to have_attributes(type: 'BKPV', one_day_kwh: 0)
        end
      end

      context 'with insufficient production readings' do
        let(:commissioned_date) { Date.new(2026, 5, 1) }

        it 'leaves the production readings unchanged' do
          expect(group_ranges_by_type(solar_production_meter)).to \
            eq({ ORIG: start_date..end_date, BKPV: commissioned_date.prev_day..start_date.prev_day })
          expect(group_ranges_by_type(solar_export_meter)).to eq(expected_ranges_by_type(solar_export_meter))
        end
      end

      context 'without export monitoring' do
        let(:solar_export_meter) { nil }

        it 'uses the backfilled generation to calculate self consumption' do
          expect(group_ranges_by_type(solar_production_meter)).to \
            eq(expected_ranges_by_type(solar_production_meter, zero_type: :SOL0))
        end
      end
    end
  end
end
