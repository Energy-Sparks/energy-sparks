# frozen_string_literal: true

require 'rails_helper'

describe AggregateDataServiceStorageHeaters do
  subject(:service) { described_class.new(meter_collection) }

  let(:meter_collection) do
    build(:meter_collection)
  end

  let!(:electricity_meter) do
    meter = build(:meter, :with_storage_heater, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
    meter_collection.add_electricity_meter(meter)
    meter
  end

  shared_examples 'a successfully aggregated storage heater setup' do
    it 'sets the aggregate meters' do
      expect(meter_collection.aggregated_electricity_meters).not_to be_nil
      expect(meter_collection.storage_heater_meter).not_to be_nil
    end

    it 'configures the aggregate sub_meters' do
      expect(meter_collection.aggregated_electricity_meters.sub_meters[:mains_consume]).not_to be_nil
      expect(meter_collection.aggregated_electricity_meters.sub_meters[:storage_heaters]).not_to be_nil
    end

    it 'has calculated the storage_heater usage' do
      expect(meter_collection.storage_heater_meter.amr_data.total).not_to eq(0.0)
    end
  end

  shared_examples 'a successfully totalled storage heater setup' do
    let(:meters_total) { to_total.map(&:amr_data).map(&:total).sum }

    it 'has allocated the electricity consumption across the aggregate and storage heater meters' do
      aggregated_electricity_meter = meter_collection.aggregated_electricity_meters
      total_aggregate = aggregated_electricity_meter.amr_data.total
      total_storage = meter_collection.storage_heater_meter.amr_data.total
      expect(total_aggregate + total_storage).to eq(meters_total)
    end

    it 'has totaled the mains consumption' do
      aggregated_electricity_meter = meter_collection.aggregated_electricity_meters
      total_mains_consume = aggregated_electricity_meter.sub_meters[:mains_consume].amr_data.total
      expect(total_mains_consume).to eq(meters_total)
    end
  end

  describe '#disaggregate' do
    context 'with single electricity meter' do
      context 'when there are no solar panels' do
        before do
          service.disaggregate
        end

        it_behaves_like 'a successfully aggregated storage heater setup'

        it 'replaces the meter with storage heaters attached with a new synthetic meter' do
          expect(meter_collection.electricity_meters.first).not_to eq(electricity_meter)
          expect(meter_collection.electricity_meters.first.synthetic_mpan_mprn?).to be true
        end

        it 'assigns the original electricity meter as the mains_consume sub_meter' do
          expect(meter_collection.electricity_meters.first.sub_meters[:mains_consume]).to eq(electricity_meter)
        end
      end

      context 'when there are solar panels' do
        before do
          electricity_meter.sub_meters[:generation] = build(:meter, type: :solar_pv)
          electricity_meter.sub_meters[:export] = build(:meter, type: :exported_solar_pv)
          electricity_meter.sub_meters[:self_consume] = build(:meter, type: :electricity)
          electricity_meter.sub_meters[:mains_consume] = build(:meter, type: :electricity)

          service.disaggregate
        end

        it_behaves_like 'a successfully aggregated storage heater setup'

        it 'replaces the meter with storage heaters attached with a new synthetic meter' do
          expect(meter_collection.electricity_meters.first).not_to eq(electricity_meter)
          expect(meter_collection.electricity_meters.first.synthetic_mpan_mprn?).to be true
        end

        it 'copies the solar sub meters to the new synthetic meter' do
          sub_meters = meter_collection.electricity_meters.first.sub_meters
          expect(sub_meters[:generation]).to eq(electricity_meter.sub_meters[:generation])
          expect(sub_meters[:export]).to eq(electricity_meter.sub_meters[:export])
          expect(sub_meters[:self_consume]).to eq(electricity_meter.sub_meters[:self_consume])
        end

        it 'assigns the original mains consumption as a sub_meter of the new synthetic meter' do
          sub_meters = meter_collection.electricity_meters.first.sub_meters
          expect(sub_meters[:mains_consume]).to eq(electricity_meter.sub_meters[:mains_consume])
        end
      end
    end

    context 'with multiple electricity meters' do
      let(:meter_attributes) { {} }
      let!(:second_meter) do
        meter = build(:meter, type: :electricity, amr_data: build(:amr_data,
                                                                  :with_date_range,
                                                                  type: :electricity,
                                                                  start_date: Date.new(2023, 1, 1),
                                                                  end_date: Date.new(2023, 12, 31),
                                                                  kwh_data_x48: Array.new(48, 1.0)))
        meter_collection.add_electricity_meter(meter)
        meter
      end

      context 'when there are no solar panels' do
        before do
          service.disaggregate
        end

        context 'when there is a single storage heater' do
          it_behaves_like 'a successfully aggregated storage heater setup'

          it 'replaces the meter with storage heaters attached with a new synthetic meter' do
            expect(meter_collection.electricity_meters.first).not_to eq(electricity_meter)
            expect(meter_collection.electricity_meters.first.synthetic_mpan_mprn?).to be true
            # unchanged as no storage heaters on this one
            expect(meter_collection.electricity_meters.last).to eq(second_meter)
          end

          it_behaves_like 'a successfully totalled storage heater setup' do
            let(:to_total) { [electricity_meter, second_meter] }
          end
        end

        context 'when there are two storage heaters on different meters' do
          let!(:second_meter) do
            meter = build(:meter, :with_storage_heater, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
            meter_collection.add_electricity_meter(meter)
            meter
          end

          it_behaves_like 'a successfully aggregated storage heater setup'

          it 'replaces the meters with storage heaters attached with new synthetic meters' do
            expect(meter_collection.electricity_meters.first).not_to eq(electricity_meter)
            expect(meter_collection.electricity_meters.first.synthetic_mpan_mprn?).to be true

            expect(meter_collection.electricity_meters.last).not_to eq(second_meter)
            expect(meter_collection.electricity_meters.last.synthetic_mpan_mprn?).to be true
          end

          it_behaves_like 'a successfully totalled storage heater setup' do
            let(:to_total) { [electricity_meter, second_meter] }
          end
        end
      end

      context 'when there are solar panels' do
        before do
          # NOTE: we're testing this class independently of the solar aggregation, so this
          # setup of submeters mimics the output of that. There's tests for this around that
          # class
          electricity_meter.sub_meters[:generation] = build(:meter, type: :solar_pv)
          electricity_meter.sub_meters[:export] = build(:meter, type: :exported_solar_pv)
          electricity_meter.sub_meters[:self_consume] = build(:meter, type: :electricity)
          electricity_meter.sub_meters[:mains_consume] = build(:meter, type: :electricity)
          # solar step always assigns a meter without panels as being its own mains_consume sub_meter
          second_meter.sub_meters[:mains_consume] = second_meter

          service.disaggregate
        end

        it_behaves_like 'a successfully aggregated storage heater setup'

        it 'replaces the meter with storage heaters attached with a new synthetic meter' do
          expect(meter_collection.electricity_meters.first).not_to eq(electricity_meter)
          expect(meter_collection.electricity_meters.first.synthetic_mpan_mprn?).to be true
          # unchanged as no storage heaters on this one
          expect(meter_collection.electricity_meters.last).to eq(second_meter)
        end

        it 'correctly assigns the original mains consumption meters' do
          # for meter with solar panels, the mains_consume should refer to the original (pre-solar) mains_consume
          sub_meters = meter_collection.electricity_meters.first.sub_meters
          expect(sub_meters[:mains_consume]).to eq(electricity_meter.sub_meters[:mains_consume])

          sub_meters = meter_collection.electricity_meters.last.sub_meters
          expect(sub_meters[:mains_consume]).to eq(second_meter)
        end

        it_behaves_like 'a successfully totalled storage heater setup' do
          let(:to_total) { [electricity_meter, second_meter] }
        end

        context 'when there are two storage heaters on different meters' do
          let!(:second_meter) do
            meter = build(:meter, :with_storage_heater, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
            meter_collection.add_electricity_meter(meter)
            meter
          end

          it_behaves_like 'a successfully aggregated storage heater setup'

          it 'replaces the meters with storage heaters attached with new synthetic meters' do
            expect(meter_collection.electricity_meters.first).not_to eq(electricity_meter)
            expect(meter_collection.electricity_meters.first.synthetic_mpan_mprn?).to be true

            expect(meter_collection.electricity_meters.last).not_to eq(second_meter)
            expect(meter_collection.electricity_meters.last.synthetic_mpan_mprn?).to be true
          end

          it_behaves_like 'a successfully totalled storage heater setup' do
            let(:to_total) { [electricity_meter, second_meter] }
          end

          it 'correctly assigns the original mains consumption meters' do
            # for meter with solar panels, the mains_consume should refer to the original (pre-solar) mains_consume
            sub_meters = meter_collection.electricity_meters.first.sub_meters
            expect(sub_meters[:mains_consume]).to eq(electricity_meter.sub_meters[:mains_consume])

            # no panels on the second meter, so the new synthetic meter should refer to the
            # original
            sub_meters = meter_collection.electricity_meters.last.sub_meters
            expect(sub_meters[:mains_consume]).to eq(second_meter)
          end
        end
      end
    end
  end
end
