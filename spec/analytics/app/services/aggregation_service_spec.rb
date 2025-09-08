# frozen_string_literal: true

require 'rails_helper'

# https://github.com/rollbar/rollbar-gem/blob/63c68eed6a8066cdd8e09ab5429728d187482b12/lib/rollbar/plugins/error_context.rb
class FakeRollbarError < StandardError
  attr_accessor :rollbar_context
end

describe AggregateDataService, type: :service do
  describe '#validate_meter_data' do
    context 'when validation fails' do
      let(:school)                  { build(:analytics_school) }
      let(:meter_collection)        { build(:meter_collection) }
      let(:service)                 { described_class.new(meter_collection) }
      let(:meter)                   { build(:meter) }

      # it "should validate empty readings" do
      #   meter_collection.add_heat_meter(meter)
      #   service.validate_meter_data.inspect
      # end

      it 'bubbles up exception' do
        allow_any_instance_of(Aggregation::ValidateAmrData).to receive(:validate).and_raise('boom')
        meter_collection.add_heat_meter(meter)
        expect { service.validate_meter_data }.to raise_error(RuntimeError)
      end

      it 'adds context to Exception when Rollbar context is available' do
        error = FakeRollbarError.new
        meter_collection.add_heat_meter(meter)
        allow_any_instance_of(Aggregation::ValidateAmrData).to receive(:validate).and_raise(error)
        expect { service.validate_meter_data }.to raise_error(FakeRollbarError)
        expect(error.rollbar_context).to eql({
                                               mpan_mprn: meter.id
                                             })
      end
    end
  end

  describe '#aggregate_heat_and_electricity_meters' do
    subject(:result) { described_class.new(meter_collection).validate_and_aggregate_meter_data }

    let(:meter_collection) do
      build(:meter_collection)
    end

    before do
      electricity_meters.each { |meter| meter_collection.add_electricity_meter(meter) }
    end

    context 'with single electricity meter' do
      let(:electricity_meters) do
        [build(:meter, meter_collection: meter_collection, type: :electricity)]
      end

      it 'uses that meter as the aggregate' do
        expect(result.aggregated_electricity_meters).to eq(electricity_meters.first)
      end
    end

    context 'with multiple electricity meters' do
      subject(:aggregate_meter) { result.aggregated_electricity_meters }

      let(:electricity_meters) do
        [
          build(:meter, meter_collection: meter_collection, type: :electricity),
          build(:meter, meter_collection: meter_collection, type: :electricity)
        ]
      end

      it 'creates an AggregateMeter' do
        expect(aggregate_meter).to be_a Dashboard::AggregateMeter
        expect(aggregate_meter.constituent_meters).to eq(electricity_meters)
        expect(aggregate_meter.mpan_mprn).to eq(Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(meter_collection.urn, :electricity))
      end

      it 'correctly identifies presence of solar' do
        expect(aggregate_meter.sheffield_simulated_solar_pv_panels?).to be(false)
        expect(aggregate_meter.solar_pv_real_metering?).to be(false)
      end

      context 'when there is sheffield solar' do
        let(:electricity_meters) do
          solar_attributes = { solar_pv: [{ start_date: Date.new(2023, 1, 1), kwp: 10.0 }] }
          [
            build(:meter, meter_collection: meter_collection, type: :electricity, meter_attributes: solar_attributes),
            build(:meter, meter_collection: meter_collection, type: :electricity)
          ]
        end

        it 'correctly identifies presence of solar' do
          expect(aggregate_meter.sheffield_simulated_solar_pv_panels?).to be(true)
          expect(aggregate_meter.solar_pv_real_metering?).to be(false)
        end
      end

      context 'when there is metered solar' do
        let(:solar_production_meter) { build(:meter, meter_collection: meter_collection, type: :solar_pv) }
        let(:solar_pv_mpan_meter_mapping) do
          {
            start_date: Date.new(2023, 1, 1),
            production_mpan: solar_production_meter.mpan_mprn.to_s
          }
        end

        let(:electricity_meters) do
          solar_attributes = { solar_pv_mpan_meter_mapping: [solar_pv_mpan_meter_mapping] }
          [
            build(:meter, meter_collection: meter_collection, type: :electricity, meter_attributes: solar_attributes),
            build(:meter, meter_collection: meter_collection, type: :electricity),
            solar_production_meter
          ]
        end

        it 'correctly identifies presence of solar' do
          expect(aggregate_meter.sheffield_simulated_solar_pv_panels?).to be(false)
          expect(aggregate_meter.solar_pv_real_metering?).to be(true)
        end

        it 'creates an AggregateMeter' do
          expect(aggregate_meter).to be_a Dashboard::AggregateMeter
          expect(aggregate_meter.mpan_mprn).to eq(Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(meter_collection.urn, :electricity))
        end

        it 'has updated the list of electricity meters' do
          expect(result.electricity_meters.count).to eq(2)
        end
      end
    end
  end
end
