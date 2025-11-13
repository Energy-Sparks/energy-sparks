# frozen_string_literal: true

require 'rails_helper'

describe Usage::PeakUsageBenchmarkingService, :aggregate_failures, type: :service do
  subject(:service) { described_class.new(meter_collection: meter_collection, asof_date: asof_date) }

  let(:asof_date) { Date.new(2022, 1, 1) }
  let(:start_date) { asof_date - 59.days }
  let(:meter_collection) do
    amr_data = build(:amr_data, :with_date_range, start_date: start_date, kwh_data_x48: [50] * 48)
    amr_data.set_carbon_emissions(
      1, nil, build(:grid_carbon_intensity, :with_days, start_date: start_date, kwh_data_x48: [0.2] * 48)
    )
    collection = build(:meter_collection, start_date: start_date)
    meter = build(:meter, :with_flat_rate_tariffs,
                  meter_collection: collection, type: :electricity, amr_data: amr_data)
    collection.set_aggregate_meter(:electricity, meter)
    collection
  end

  describe '#estimated_savings' do
    it 'returns estimated savings when compared against an benchmark school' do
      allow(BenchmarkMetrics).to receive(:benchmark_peak_kw).and_return(89.0)
      savings = service.estimated_savings(versus: :benchmark_school)
      expect(savings.kwh).to be_within(0.01).of(96_360)
      expect(savings.£).to be_within(0.01).of(9_636)
      expect(savings.co2).to be_within(0.01).of(19_272)
      expect(savings.percent).to be_nil
    end

    it 'returns estimated savings when compared against an examplar school' do
      allow(BenchmarkMetrics).to receive(:exemplar_peak_kw).and_return(78.0)
      savings = service.estimated_savings(versus: :exemplar_school)
      expect(savings.kwh).to be_within(0.01).of(192_720)
      expect(savings.£).to be_within(0.01).of(19_272)
      expect(savings.co2).to be_within(0.01).of(38_544)
      expect(savings.percent).to be_nil
    end
  end

  describe '#average_peak_usage_kw' do
    it 'returns average peak usage kw when compared against an examplar school' do
      allow(BenchmarkMetrics).to receive(:exemplar_peak_kw).and_return(78.0)
      expect(service.average_peak_usage_kw(compare: :exemplar_school)).to be_within(0.01).of(78)
    end

    it 'returns average peak usage kw when compared against a benchmark school' do
      allow(BenchmarkMetrics).to receive(:benchmark_peak_kw).and_return(89.0)
      expect(service.average_peak_usage_kw(compare: :benchmark_school)).to be_within(0.01).of(89)
    end
  end
end
