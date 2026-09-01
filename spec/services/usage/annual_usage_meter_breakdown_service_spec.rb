# frozen_string_literal: true

require 'rails_helper'

describe Usage::AnnualUsageMeterBreakdownService, :aggregate_failures, type: :service do
  let(:asof_date) { nil }
  let(:fuel_type) { :electricity }
  let(:service) { described_class.new(meter_collection, fuel_type, asof_date) }

  describe '#calculate_breakdown' do
    let(:usage_breakdown) { service.calculate_breakdown }
    let(:mpan) { meter_collection.all_meters.first.mpan_mprn }

    def format_unit(unit, val)
      FormatUnit.format(unit, val, :html, true, true)
    end

    shared_examples 'it calculates the expected values' do
      let(:meter_collection) do
        build(:meter_collection, :with_aggregated_aggregate_meter,
              fuel_type:,
              start_date: Date.new(2021, 10), end_date: Date.new(2023, 10),
              kwh_data_x48: nil, random_generator: Random.new(18))
      end

      it 'calculates the expected dates' do
        expect(usage_breakdown.start_date).to eq(Date.new(2022, 10, 2))
        expect(usage_breakdown.end_date).to eq(Date.new(2023, 9, 30))
      end

      it 'calculates the expected annual_percent_change' do
        percent = usage_breakdown.annual_percent_change(mpan)
        expect(format_unit(:relative_percent, percent)).to eq '+0.478&percnt;'
      end

      def co2_usage = fuel_type == :gas ? '1,590' : '2,210'

      it 'calculates the expected usage' do
        usage = usage_breakdown.usage(mpan)
        expect(format_unit(:kwh, usage.kwh)).to eq '8,730'
        expect(format_unit(:co2, usage.co2)).to eq co2_usage
        expect(format_unit(:£, usage.£)).to eq '&pound;873'
        expect(format_unit(:percent, usage.percent)).to eq '100&percnt;'
      end

      it 'calculates the expected total_annual_percent_change' do
        percent = usage_breakdown.total_annual_percent_change
        expect(format_unit(:relative_percent, percent)).to eq '+0.478&percnt;'
      end

      it 'calculates the expected total_usage' do
        expect(format_unit(:kwh, usage_breakdown.total_usage.kwh)).to eq '8,730'
        expect(format_unit(:co2, usage_breakdown.total_usage.co2)).to eq co2_usage
        expect(format_unit(:£, usage_breakdown.total_usage.£)).to eq '&pound;873'
        expect(format_unit(:percent, usage_breakdown.total_usage.percent)).to eq '100&percnt;'
      end
    end

    context 'with electricity' do
      context 'with two years data' do
        it_behaves_like 'it calculates the expected values'
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      context 'with two years data' do
        it_behaves_like 'it calculates the expected values'
      end
    end
  end
end
