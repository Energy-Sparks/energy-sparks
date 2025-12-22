# frozen_string_literal: true

require 'rails_helper'

describe AggregatorBenchmarks do
  subject(:aggregator) do
    described_class.new(meter_collection, chart_config, aggregator_results)
  end

  let(:chart_config) do
    {
      chart1_type: :bar,
      chart1_subtype: :stacked,
      meter_definition: :all,
      x_axis: :year,
      series_breakdown: :fuel,
      yaxis_units: :kwh,
      yaxis_scaling: :none,
      inject: :benchmark
    }
  end

  shared_examples 'the benchmark series have been injected' do |fuels:|
    it 'adds series to x_axis' do
      expect(aggregator_results.x_axis).to include(AggregatorBenchmarks::BENCHMARK_SCHOOL_NAME)
      expect(aggregator_results.x_axis).to include(AggregatorBenchmarks::EXEMPLAR_SCHOOL_NAME)
    end

    it 'adds calculated usage' do
      # Should include one non-zero value for each type of benchmark school
      fuels.each do |fuel|
        expect(aggregator_results.bucketed_data[fuel].length).to eq(4)
        expect(aggregator_results.bucketed_data[fuel].all? { |x| x > 0.0 }).to be true
      end
    end
  end

  describe '#inject_benchmarks' do
    context 'with a single series' do
      # Sets up the results as they would be following calculation of individual series
      # in this case, benchmarking usage over 2 years.
      #
      # Note: these ignore the meter dates in the meter collection. Those are provided
      # to allow the calculations to work, the dates here are to just allow us to test
      # the code in isolation.
      let(:aggregator_results) do
        one_year_ago = Date.today - 365
        AggregatorResults.new(
          x_axis: %w[this_year last_year],
          bucketed_data: { series_name => [1000.0, 12_000.0] },
          x_axis_bucket_date_ranges: [[one_year_ago, Date.today], [one_year_ago - 365, one_year_ago]],
          bucketed_data_count: { series_name => [1, 1] }
        )
      end

      context 'with an electricity series' do
        let(:meter_collection) do
          build(:meter_collection, :with_aggregated_aggregate_meter, fuel_type: :electricity, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
        end
        before { aggregator.inject_benchmarks }

        let(:series_name) { 'electricity' }

        it_behaves_like 'the benchmark series have been injected', fuels: ['electricity']
      end

      context 'with a gas series' do
        let(:meter_collection) do
          build(:meter_collection, :with_aggregated_aggregate_meter, fuel_type: :gas, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
        end
        before { aggregator.inject_benchmarks }

        let(:series_name) { 'gas' }

        it_behaves_like 'the benchmark series have been injected', fuels: ['gas']
      end

      context 'with a storage heater series' do
        let(:meter_collection) do
          build(:meter_collection, :with_aggregated_aggregate_meter, fuel_type: :electricity, start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31), storage_heaters: true)
        end
        let(:series_name) { 'storage heaters' }

        before { aggregator.inject_benchmarks }

        it_behaves_like 'the benchmark series have been injected', fuels: ['storage heaters']
      end
    end

    context 'with two series' do
      let(:bucketed_data) do
        {
          'electricity' => [1000.0, 12_000.0],
          'gas' => [1000.0, 12_000.0]
        }
      end

      let(:aggregator_results) do
        one_year_ago = Date.today - 365
        AggregatorResults.new(
          x_axis: %w[this_year last_year],
          bucketed_data: bucketed_data,
          x_axis_bucket_date_ranges: [[one_year_ago, Date.today], [one_year_ago - 365, one_year_ago]],
          bucketed_data_count: bucketed_data
        )
      end

      context 'with a gas and electricity series' do
        let(:meter_collection) do
          build(:meter_collection, :with_electricity_and_gas_meters,
                start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 12, 31))
        end

        before do
          AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
          aggregator.inject_benchmarks
        end

        it_behaves_like 'the benchmark series have been injected', fuels: %w[electricity gas]
      end
    end
  end
end
