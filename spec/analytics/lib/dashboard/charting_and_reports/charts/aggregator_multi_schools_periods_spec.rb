# frozen_string_literal: true

require 'rails_helper'

describe AggregatorMultiSchoolsPeriods do
  subject(:aggregator) do
    described_class.new(meter_collection, chart_config, nil)
  end

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

  let(:amr_start_date) { Date.new(2023, 1, 2) } # 52 weeks before end
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
  let(:amr_end_date) { Date.new(2023, 12, 31) }

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

          it 'has the correct data' do
            expect(aggregator.results.x_axis).to eq(%w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec])
            expect(aggregator.results.bucketed_data).to eq(
              { 'Mon 02 Jan 23-Sun 31 Dec 23' =>
                  [30, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].map(&daily_usage.method(:*)) }
            )
          end
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

        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec Jan])
          # in this instance the two series should have the same number of entries
          # otherwise the monthly values for the current and previous years dont align on the chart
          # The two series will be:
          # 2023-01-18 - 2024-01-16 = [Jan, Feb,...Dec, Jan]
          # 2022-10-01 - 2023-01-17 = [Oct, Nov, Dec, Jan]
          #
          # The four months should be at the end of the range
          # Oct, Nov, Dec, and 17 days in Jan
          expect(aggregator.results.bucketed_data).to eq(
            { 'Sat 01 Oct 22-Tue 17 Jan 23' =>
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 30, 31, 17].map(&daily_usage.method(:*)),
              'Wed 18 Jan 23-Tue 16 Jan 24' =>
               [14, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 16].map(&daily_usage.method(:*)) }
          )
        end
      end

      context 'when there is over two years data' do
        # Will result in 2 ranges in comparison
        # 2023-01-02 - 2023-12-31
        # 2022-01-03 - 2023-01-01
        let(:amr_start_date) { Date.new(2022, 1, 3) } # two years of 52 * 7 weeks before 2023-12-31

        before { aggregator.calculate }

        it_behaves_like 'a successful chart', series_count: 2

        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec Jan])
          expect(aggregator.results.bucketed_data).to eq(
            { 'Mon 03 Jan 22-Sun 01 Jan 23' =>
                [29, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 1].map(&daily_usage.method(:*)),
              'Mon 02 Jan 23-Sun 31 Dec 23' =>
                [30, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 0].map(&daily_usage.method(:*)) }
          )
        end
      end
    end

    context 'with two periods of :academicyear' do # TODO: remove as not currently used?
      let(:timescale) { [{ academicyear: 0 }, { academicyear: -1 }] }

      before { aggregator.calculate }

      context 'when there is only a year of data' do
        it_behaves_like 'a successful chart', series_count: 2
        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug])
          expect(aggregator.results.bucketed_data).to eq(
            {
              'Mon 02 Jan 23-Thu 31 Aug 23' =>
                [0, 0, 0, 0, 30, 28, 31, 30, 31, 30, 31, 31].map(&daily_usage.method(:*)),
              'Fri 01 Sep 23-Sun 31 Dec 23' =>
                [30, 31, 30, 31, 0, 0, 0, 0, 0, 0, 0, 0].map(&daily_usage.method(:*))
            }
          )
        end
      end

      context 'with year not starting on a month boundary' do
        let(:holidays) do
          Holidays.new(
            HolidayData.new(
              [build(:holiday, name: 'Summer', start_date: Date.new(2023, 7, 22), end_date: Date.new(2023, 9, 3))]
            ), nil
          )
        end

        it_behaves_like 'a successful chart', series_count: 2
        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug Sep])
          expect(aggregator.results.bucketed_data).to eq(
            {
              'Mon 02 Jan 23-Sun 03 Sep 23' =>
                [0, 0, 0, 0, 30, 28, 31, 30, 31, 30, 31, 31, 3].map(&daily_usage.method(:*)),
              'Mon 04 Sep 23-Sun 31 Dec 23' =>
                [27, 31, 30, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0].map(&daily_usage.method(:*))
            }
          )
        end
      end

      context 'when there is over a year of data' do
        let(:amr_start_date) { Date.new(2022, 6, 1) }

        it_behaves_like 'a successful chart', series_count: 2
        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug])
          expect(aggregator.results.bucketed_data).to eq(
            { 'Wed 01 Jun 22-Thu 31 Aug 23' =>
                [30, 31, 31, 30, 31, 30, 31, 31, 28, 31, 30, 31, 30, 31, 31].map(&daily_usage.method(:*)),
              'Fri 01 Sep 23-Sun 31 Dec 23' =>
                [0, 0, 0, 30, 31, 30, 31, 0, 0, 0, 0, 0, 0, 0, 0].map(&daily_usage.method(:*)) }
          )
        end
      end

      context 'when data starts after the beginning of the academic year' do
        let(:amr_start_date) { Date.new(2022, 10, 1) }

        it_behaves_like 'a successful chart', series_count: 2
        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug])
        end
      end
    end

    context 'with two periods of :fixed_academic_year' do
      let(:timescale) { [{ fixed_academic_year: 0 }, { fixed_academic_year: -1 }] }

      before { aggregator.calculate }

      context 'when there is only a year of data' do
        it_behaves_like 'a successful chart', series_count: 2
        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug])
          expect(aggregator.results.bucketed_data).to eq(
            { 'Mon 02 Jan 23-Thu 31 Aug 23' =>
                [0, 0, 0, 0, 30, 28, 31, 30, 31, 30, 31, 31].map(&daily_usage.method(:*)),
              'Fri 01 Sep 23-Sun 31 Dec 23' =>
                [30, 31, 30, 31, 0, 0, 0, 0, 0, 0, 0, 0].map(&daily_usage.method(:*)) }
          )
        end
      end

      context 'when data starts after the beginning of the academic year' do
        let(:amr_start_date) { Date.new(2022, 2, 16) }
        let(:amr_end_date) { Date.new(2023, 3, 29) }

        it_behaves_like 'a successful chart', series_count: 2
        it 'has the correct data' do
          expect(aggregator.results.x_axis).to eq(%w[Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug])
          expect(aggregator.results.bucketed_data).to eq(
            {
              'Wed 16 Feb 22-Wed 31 Aug 22' =>
                [0, 0, 0, 0, 0, 13, 31, 30, 31, 30, 31, 31].map(&daily_usage.method(:*)),
              'Thu 01 Sep 22-Wed 29 Mar 23' =>
                [30, 31, 30, 31, 31, 28, 29, 0, 0, 0, 0, 0].map(&daily_usage.method(:*))
            }
          )
        end
      end
    end
  end
end
