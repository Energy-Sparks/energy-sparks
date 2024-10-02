# frozen_string_literal: true

require 'spec_helper'

describe AggregatorMultiSchoolsPeriods do
  include_context 'with an aggregated meter with tariffs and school times' do
    let(:amr_start_date)  { amr_start_date }
    let(:amr_end_date)    { amr_end_date }
  end

  shared_examples 'a successful chart' do |series_count:|
    it 'has expected date ranges' do
      expect(aggregator.min_combined_school_date).to eq amr_start_date
      expect(aggregator.max_combined_school_date).to eq amr_end_date
    end

    it 'has expected number of series' do
      expect(aggregator.results.bucketed_data.size).to eq series_count
    end
  end

  let(:amr_start_date)  { Date.new(2023, 1, 2) } # 52 weeks before end
  let(:amr_end_date)    { Date.new(2023, 12, 31) }

  subject(:aggregator) do
    AggregatorMultiSchoolsPeriods.new(meter_collection, chart_config, nil)
  end

  let(:chart_config) do
    {
      chart1_type: :column,
      meter_definition: :allelectricity, # should align with fuel type of meter in shared context
      name: 'Test',
      series_breakdown: :none,
      timescale: timescale,
      x_axis: x_axis,
      yaxis_scaling: :none,
      yaxis_units: :kwh,
      ignore_single_series_failure: ignore_single_series_failure
    }
  end

  let(:ignore_single_series_failure) { false }

  context 'when plotting multiple timescales' do
    context 'with a month x-axis' do
      let(:x_axis) { :month }

      context 'with two :year periods' do
        let(:timescale) do
          [{ year: 0 }, { year: -1 }]
        end

        context 'when there is only a year of data' do
          it 'raises an exception' do
            expect { aggregator.calculate }.to raise_error(EnergySparksNotEnoughDataException)
          end
        end

        context 'when there is over a year of data' do
          let(:amr_start_date) { Date.new(2022, 6, 1) }

          it 'raises an exception' do
            expect { aggregator.calculate }.to raise_error(EnergySparksNotEnoughDataException)
          end

          context 'with ignore_single_series_failures set' do
            let(:ignore_single_series_failure) { true }

            before { aggregator.calculate }

            it_behaves_like 'a successful chart', series_count: 1
          end
        end

        context 'when there is over two years data' do
          let(:amr_start_date) { Date.new(2022, 1, 3) } # two years of 52 * 7 weeks before 2023-12-31

          before { aggregator.calculate }

          it_behaves_like 'a successful chart', series_count: 2
        end
      end

      context 'with two periods of :up_to_a_year' do
        let(:timescale) do
          [{ up_to_a_year: 0 }, { up_to_a_year: -1 }]
        end

        context 'when there is only a year of data' do
          it 'raises an exception' do
            expect { aggregator.calculate }.to raise_error(EnergySparksNotEnoughDataException)
          end

          context 'with ignore_single_series_failures set' do
            let(:ignore_single_series_failure) { true }

            before { aggregator.calculate }

            it_behaves_like 'a successful chart', series_count: 1
          end
        end

        context 'when there is over a year of data' do
          let(:amr_start_date) { Date.new(2022, 6, 1) }

          before { aggregator.calculate }

          it_behaves_like 'a successful chart', series_count: 2
          it 'has aligned the series correctly' do
            bucketed_data = aggregator.results.bucketed_data
            # in this instance the two series should have the same number of entries
            # otherwise the monthly values for the current and previous years dont align on the chart
            expect(bucketed_data.values.first.size).to eq(bucketed_data.values.last.size)
          end
        end

        context 'with less than 18 months of data' do
          let(:amr_start_date) { Date.new(2022, 10, 1) }
          let(:amr_end_date) { Date.new(2024, 1, 16) }

          before { aggregator.calculate }

          it_behaves_like 'a successful chart', series_count: 2

          it 'has aligned the series correctly' do
            bucketed_data = aggregator.results.bucketed_data
            # in this instance the two series should have the same number of entries
            # otherwise the monthly values for the current and previous years dont align on the chart
            expect(bucketed_data.values.first.size).to eq(bucketed_data.values.last.size)
            # The two series will be:
            # 2023-01-18 - 2024-01-16 = [Jan, Feb,...Dec, Jan]
            # 2022-10-01 - 2023-01-17 = [Oct, Nov, Dec, Jan]
            #
            # The four months should be at the end of the range
            daily_kwh = 48.0 * usage_per_hh # from the shared context
            # Oct, Nov, Dec, and 17 days in Jan
            monthly_usage = [daily_kwh * 31, daily_kwh * 30, daily_kwh * 31, daily_kwh * 17]
            # 9 months with no values, then the above
            expect(bucketed_data.values.last).to eq(Array.new(9, 0.0) + monthly_usage)
          end
        end

        context 'when there is over two years data' do
          # Will result in 2 ranges in comparison
          # 2023-01-02 - 2023-12-31
          # 2022-01-03 - 2023-01-01
          let(:amr_start_date) { Date.new(2022, 1, 3) } # two years of 52 * 7 weeks before 2023-12-31

          before { aggregator.calculate }

          it_behaves_like 'a successful chart', series_count: 2

          it 'has aligned the series correctly' do
            bucketed_data = aggregator.results.bucketed_data
            expect(bucketed_data.values.first.size).to eq(bucketed_data.values.last.size)
            expect(bucketed_data.values.last.all? { |kwh| kwh > 0.0 }).to be true
          end
        end
      end
    end
  end
end
