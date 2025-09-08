# frozen_string_literal: true

require 'rails_helper'

describe Aggregator do
  subject(:aggregator) { described_class.new(meter_collection, chart_config) }

  let(:start_date) { Date.new(2020, 1, 1) }
  let(:end_date)   { Date.new(2023, 12, 31) }

  let(:meter_collection) do
    build(:meter_collection, :with_electricity_and_gas_meters,
          start_date: start_date, end_date: end_date)
  end

  before do
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
  end

  shared_examples 'a successful calculation' do |y2_axis: false|
    it 'has a valid result' do
      expect(aggregator.valid?).to be(true)
    end

    it 'has populated the results' do
      expect(aggregator.x_axis).not_to be_nil
      expect(aggregator.x_axis_bucket_date_ranges).not_to be_nil
      expect(aggregator.bucketed_data).not_to be_nil
    end

    it 'has added a y2 axis', if: y2_axis do
      expect(aggregator.y2_axis).not_to be_nil
    end

    it 'has used the right meter dates' do
      expect(aggregator.first_meter_date).to eq(expected_start_date)
      expect(aggregator.last_meter_date).to eq(expected_end_date)
    end
  end

  shared_examples 'a successful benchmark chart' do
    it 'has added the benchmark school series to the x_axis' do
      expect(aggregator.x_axis).to include(AggregatorBenchmarks::BENCHMARK_SCHOOL_NAME)
      expect(aggregator.x_axis).to include(AggregatorBenchmarks::EXEMPLAR_SCHOOL_NAME)
      expect(aggregator.x_axis.length).to be > 2 # ensure there are other values in series
    end
  end

  shared_examples 'a chart broken down by fuel' do
    it 'broken down results by fuel' do
      expect(aggregator.bucketed_data.keys).to match_array(expected_fuels)
    end
  end

  # 4 years for default start/end
  shared_examples 'a chart with the right timescale' do |series: 4|
    it 'has the right number of series values' do
      expect(aggregator.bucketed_data.values.all? { |v| v.length == series }).to be true
    end
  end

  describe '#aggregate' do
    describe 'with a series breakdown by fuel' do
      let(:chart_config) do
        {
          name: 'Test benchmark chart',
          meter_definition: :all,
          x_axis: :year,
          series_breakdown: :fuel,
          yaxis_units: :kwh
        }
      end

      before { aggregator.aggregate }

      it_behaves_like 'a successful calculation' do
        let(:expected_start_date) { start_date }
        let(:expected_end_date) { end_date }
      end

      it_behaves_like 'a chart broken down by fuel' do
        let(:expected_fuels) { %w[electricity gas] }
      end

      context 'with no timescale' do
        it_behaves_like 'a chart with the right timescale'
      end

      context 'with a restriction on timescale' do
        let(:chart_config) do
          {
            name: 'Test benchmark chart',
            meter_definition: :all,
            x_axis: :year,
            series_breakdown: :fuel,
            yaxis_units: :kwh,
            timescale: :year
          }
        end

        it_behaves_like 'a chart with the right timescale', series: 1
      end

      context 'with a filter on the fuels' do
        let(:chart_config) do
          {
            name: 'Test benchmark chart',
            meter_definition: :all,
            x_axis: :year,
            series_breakdown: :fuel,
            yaxis_units: :kwh,
            filter: { fuel: ['gas'] }
          }
        end

        it_behaves_like 'a chart broken down by fuel' do
          let(:expected_fuels) { ['gas'] }
        end
      end

      context 'with a meter definition' do
        let(:chart_config) do
          {
            name: 'Test benchmark chart',
            meter_definition: :allheat,
            x_axis: :year,
            series_breakdown: :fuel,
            yaxis_units: :kwh
          }
        end

        it_behaves_like 'a chart broken down by fuel' do
          let(:expected_fuels) { ['gas'] }
        end
      end

      context 'with a y2 axis' do
        let(:chart_config) do
          {
            name: 'Test benchmark chart',
            meter_definition: :all,
            x_axis: :year,
            series_breakdown: :fuel,
            yaxis_units: :kwh,
            y2_axis: :irradiance
          }
        end

        it_behaves_like 'a successful calculation', y2_axis: true do
          let(:y2_axis) { true }
          let(:expected_start_date) { start_date }
          let(:expected_end_date) { end_date }
        end
      end
    end

    describe 'with a chart with benchmarks injected' do
      let(:chart_config) do
        {
          name: 'Test benchmark chart',
          meter_definition: :all,
          x_axis: :year,
          series_breakdown: :fuel,
          yaxis_units: :kwh,
          inject: :benchmark
        }
      end

      before { aggregator.aggregate }

      it_behaves_like 'a successful calculation' do
        let(:expected_start_date) { start_date }
        let(:expected_end_date) { end_date }
      end

      it_behaves_like 'a successful benchmark chart'

      it_behaves_like 'a chart broken down by fuel' do
        let(:expected_fuels) { %w[electricity gas] }
      end

      it_behaves_like 'a chart with the right timescale', series: 6 # 4 years, plus 2 for benchmarks
    end

    describe 'with a thermostatic regression' do
      let(:chart_config) do
        {
          name: 'Test thermostatic chart',
          chart1_type: :scatter,
          meter_definition: :allheat,
          timescale: :up_to_a_year,
          series_breakdown: %i[model_type temperature],
          x_axis: :day,
          yaxis_units: :kwh,
          yaxis_scaling: :none
        }
      end

      # TEMPORARY use anonymised data until we've implemented approach for creating synthetic
      # AMR / Temperature / Holiday data to allow heating models to work
      let(:meter_collection) do
        load_unvalidated_meter_collection(school: 'acme-academy', validate_and_aggregate: true)
      end

      before { aggregator.aggregate }

      it_behaves_like 'a successful calculation' do
        let(:expected_start_date) { Date.new(2018, 9, 1) }
        let(:expected_end_date) { Date.new(2023, 10, 10) }
      end
    end
  end
end
