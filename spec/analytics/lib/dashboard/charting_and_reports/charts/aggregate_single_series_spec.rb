# frozen_string_literal: true

require 'rails_helper'

# For testing of the AggregatorSingleSeries and its integration with
# the period and bucketing classes.
#
# Add tests for those individual classes rather than overloading this spec
# with all charting combinations.
describe AggregatorSingleSeries do
  # Meter date ranges
  let(:meter_start_date) { Date.new(2020, 1, 1) }
  let(:aggregator_results) { AggregatorResults.new }
  let(:aggregator) { described_class.new(meter_collection, chart_config, aggregator_results) }
  let(:meter_end_date) { Date.new(2023, 1, 1) }

  # Setup stubs
  let(:amr_data) { double('amr-data') }
  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter') }
  let(:meter_collection)            { double('meter-collection') }

  # Configure the stubs to return expected data
  before do
    allow(community_use_breakdown).to receive(:series_names).and_return(series_names)
    allow(amr_data).to receive(:start_date).and_return(meter_start_date)
    allow(amr_data).to receive(:end_date).and_return(meter_end_date)
    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:name).and_return('Meter collection')
  end

  context 'with a weekly axis and a day type breakdown' do
    # Existing school dashboard chart config, but without community use config
    #
    # Min/max dates in this configuration should align with min/max
    # dates used in tests. These are currently added by the Aggregator class
    # which modifies chart config before running.
    let(:chart_config) do
      {
        chart1_subtype: :stacked,
        chart1_type: :column,
        meter_definition: :allelectricity,
        name: 'By Week: Electricity',
        series_breakdown: :daytype,
        timescale: timescale,
        x_axis: :week,
        yaxis_scaling: :none,
        yaxis_units: :kwh,
        min_combined_school_date: meter_start_date,
        max_combined_school_date: meter_end_date
      }
    end

    # Community use breakdown set on the amr data by the aggregator
    # used by series data manager to create day type names
    let(:community_use_breakdown) { double('community-use-breakdown') }
    let(:series_names) { %i[holiday weekend school_day_open school_day_closed] }

    # return flat line for every day of data
    # using a hash because the chart config uses a daytype breakdown
    # if testing other charts, then need to return different data from amr_data stub
    let(:one_day_kwh_breakdown) do
      { school_day_open: 20.0 }
    end

    before do
      allow(amr_data).to receive(:open_close_breakdown).and_return(community_use_breakdown)
      allow(amr_data).to receive(:one_day_kwh).and_return(one_day_kwh_breakdown)
    end

    context 'with timescale up_to_one_year' do
      let(:timescale) { :up_to_a_year }
      # Sunday to Saturday 15th January 2022
      let(:expected_x_axis_start_range) do
        [expected_x_axis_start_date, expected_x_axis_start_date + 6]
      end
      # with data ending on 2023-01-01, the x_axis date will be the first Sunday
      # of the period, which is 9th January 2022
      # NOTE: with revised code this becomes a week earlier
      let(:expected_x_axis_start_date) { Date.new(2022, 1, 2) }
      # Sunday 25th December to Saturday
      let(:expected_x_axis_end_range) do
        [expected_x_axis_end_date - 6, expected_x_axis_end_date]
      end
      # with data ending on 2023-01-01, and with the graph NOT showing partial final weeks,
      # then the final range end on Saturday 31st December 2022
      let(:expected_x_axis_end_date) { Date.new(2022, 12, 31) }
      # with data ending on 2023-01-01, and with the graph NOT showing partial final weeks,
      # then the final range end on Saturday 31st December 2022
      let(:expected_x_axis_end_date) { Date.new(2022, 12, 31) }
      # Sunday 25th December to Saturday
      let(:expected_x_axis_end_range) do
        [expected_x_axis_end_date - 6, expected_x_axis_end_date]
      end
      # with data ending on 2023-01-01, the x_axis date will be the first Sunday
      # of the period, which is 9th January 2022
      # NOTE: with revised code this becomes a week earlier
      let(:expected_x_axis_start_date) { Date.new(2022, 1, 2) }
      # Sunday to Saturday 15th January 2022
      let(:expected_x_axis_start_range) do
        [expected_x_axis_start_date, expected_x_axis_start_date + 6]
      end

      before do
        # write results into the aggregator_results
        aggregator.aggregate_period
      end

      it 'populates the result object' do
        expect(aggregator_results.series_manager).not_to be_nil
        expect(aggregator_results.xbucketor).not_to be_nil
      end

      it 'populates the bucketed data' do
        keys = ['Holiday', 'Weekend', 'School Day Open', 'School Day Closed']
        expect(aggregator_results.bucketed_data.keys).to match_array(keys)
        keys.each do |key|
          expect(aggregator_results.bucketed_data[key].any?(:nil?)).to eq false
        end
        expect(aggregator_results.bucketed_data['School Day Open'].first).to eq 140.0
        expect(aggregator_results.bucketed_data_count.keys).to match_array(keys)
      end

      it 'produces the right series names' do
        expect(aggregator_results.series_names).to eq series_names
      end

      it 'populates the x axis' do
        # currently produces 51 week view...
        expect(aggregator_results.x_axis.size).to eq 52
        expect(aggregator_results.x_axis_date_ranges).not_to be_nil
        expect(aggregator_results.x_axis_date_ranges.last).to eq expected_x_axis_end_range
        expect(aggregator_results.x_axis_date_ranges.first).to eq expected_x_axis_start_range
      end

      context 'when moving back one year' do
        let(:timescale) { { up_to_a_year: -1 } }

        it 'populates the x axis' do
          # currently produces 51 week view...
          expect(aggregator_results.x_axis.size).to eq 52
          expect(aggregator_results.x_axis_date_ranges).not_to be_nil

          # having moved back a year, the final range should be the previous week from above
          # so Sunday 2nd January 2022 to Saturday 8th January 2022
          previous_year_x_axis_end_range = [expected_x_axis_start_date - 7, expected_x_axis_start_date - 1]
          expect(aggregator_results.x_axis_date_ranges.last).to eq previous_year_x_axis_end_range
        end
      end

      # this context just replicates the above few specs but substitutes different dates
      # taken from observing the current/expected behaviour on real charts
      # as a double check of the logic
      context 'with additional date tests --' do
        # all dates below taken from real example data
        let(:meter_start_date)         { Date.new(2020, 3, 1) }
        let(:meter_end_date)           { Date.new(2023, 3, 13) }
        let(:expected_x_axis_start_date) { Date.new(2022, 3, 13) }
        let(:expected_x_axis_end_date) { Date.new(2023, 3, 11) }

        it 'populates the x axis' do
          expect(aggregator_results.x_axis_date_ranges.last).to eq expected_x_axis_end_range
          expect(aggregator_results.x_axis_date_ranges.first).to eq expected_x_axis_start_range
        end

        context 'when moving back one year' do
          let(:timescale) { { up_to_a_year: -1 } }

          it 'populates the x axis' do
            # currently produces 51 week view...
            expect(aggregator_results.x_axis.size).to eq 52
            expect(aggregator_results.x_axis_date_ranges).not_to be_nil

            # having moved back a year, the final range should be the previous week from above
            # so Sunday 2nd January 2022 to Saturday 8th January 2022
            previous_year_x_axis_end_range = [expected_x_axis_start_date - 7, expected_x_axis_start_date - 1]
            expect(aggregator_results.x_axis_date_ranges.last).to eq previous_year_x_axis_end_range
          end
        end
      end

      context 'with 3 months of data' do
        let(:meter_start_date)  { Date.new(2022, 9, 1) }
        let(:meter_end_date)    { Date.new(2023, 1, 1) }

        # first sunday of range
        let(:expected_x_axis_start_date) { Date.new(2022, 9, 4) }

        it 'populates the x axis' do
          expect(aggregator_results.x_axis_date_ranges.last).to eq expected_x_axis_end_range
          expect(aggregator_results.x_axis_date_ranges.first).to eq expected_x_axis_start_range
        end
      end
    end

    context 'with timescale year' do
      let(:timescale) { :year }
      # with data ending on 2023-01-01, and with the graph NOT showing partial final weeks,
      # then the final range end on Saturday 31st December 2022
      let(:expected_x_axis_end_date) { Date.new(2022, 12, 31) }
      # Sunday 25th December to Saturday
      let(:expected_x_axis_end_range) do
        [expected_x_axis_end_date - 6, expected_x_axis_end_date]
      end
      # with data ending on 2023-01-01, the x_axis date will be the first Sunday
      # of the period, which is 9th January 2022
      # NOTE: with revised code this becomes a week earlier
      let(:expected_x_axis_start_date) { Date.new(2022, 1, 2) }
      # Sunday to Saturday 15th January 2022
      let(:expected_x_axis_start_range) do
        [expected_x_axis_start_date, expected_x_axis_start_date + 6]
      end

      before do
        # write results into the aggregator_results
        aggregator.aggregate_period
      end

      it 'populates the x axis' do
        expect(aggregator_results.x_axis.size).to eq 52
        expect(aggregator_results.x_axis_date_ranges).not_to be_nil
        expect(aggregator_results.x_axis_date_ranges.last).to eq expected_x_axis_end_range
        expect(aggregator_results.x_axis_date_ranges.first).to eq expected_x_axis_start_range
      end

      context 'when moving back one year' do
        let(:timescale) { { year: -1 } }

        it 'populates the x axis' do
          expect(aggregator_results.x_axis.size).to eq 52
          expect(aggregator_results.x_axis_date_ranges).not_to be_nil

          # having moved back a year, the final range should be the previous week from above
          # so Sunday 2nd January 2022 to Saturday 8th January 2022
          previous_year_x_axis_end_range = [expected_x_axis_start_date - 7, expected_x_axis_start_date - 1]
          expect(aggregator_results.x_axis_date_ranges.last).to eq previous_year_x_axis_end_range
        end
      end
    end
  end

  context 'with a day of week axis and a day type breakdown' do
    let(:timescale)   { :up_to_a_year }
    let(:expected_x_axis_end_range) do
      [expected_x_axis_end_date, expected_x_axis_end_date]
    end
    # it uses the latest date
    let(:expected_x_axis_end_date) { Date.new(2023, 1, 1) }
    let(:expected_x_axis_start_range) do
      [expected_x_axis_start_date, expected_x_axis_start_date]
    end
    # this chart produces one result for each day in the year
    let(:expected_x_axis_start_date) { Date.new(2022, 1, 3) }
    # this chart produces one result for each day in the year
    let(:expected_x_axis_start_date) { Date.new(2022, 1, 3) }
    let(:expected_x_axis_start_range) do
      [expected_x_axis_start_date, expected_x_axis_start_date]
    end
    # it uses the latest date
    let(:expected_x_axis_end_date) { Date.new(2023, 1, 1) }
    let(:expected_x_axis_end_range) do
      [expected_x_axis_end_date, expected_x_axis_end_date]
    end
    let(:chart_config) do
      {
        chart1_subtype: :stacked,
        chart1_type: :column,
        meter_definition: :allelectricity,
        name: 'Electricity Use By Day of the Week',
        series_breakdown: :daytype,
        subtitle: :daterange,
        timescale: timescale,
        x_axis: :dayofweek,
        yaxis_scaling: :none,
        yaxis_units: :kwh,
        min_combined_school_date: meter_start_date,
        max_combined_school_date: meter_end_date
      }
    end

    # Community use breakdown set on the amr data by the aggregator
    # used by series data manager to create day type names
    let(:community_use_breakdown) { double('community-use-breakdown') }
    let(:series_names) { %i[holiday weekend school_day_open school_day_closed] }

    # return flat line for every day of data
    # using a hash because the chart config uses a daytype breakdown
    # if testing other charts, then need to return different data from amr_data stub
    let(:one_day_kwh_breakdown) do
      { school_day_open: 10.0 }
    end

    before do
      allow(amr_data).to receive(:open_close_breakdown).and_return(community_use_breakdown)
      allow(amr_data).to receive(:one_day_kwh).and_return(one_day_kwh_breakdown)
      # write results into the aggregator_results
      aggregator.aggregate_period
    end

    it 'populates the result object' do
      expect(aggregator_results.series_manager).not_to be_nil
      expect(aggregator_results.xbucketor).not_to be_nil
    end

    it 'populates the bucketed data' do
      keys = ['Holiday', 'Weekend', 'School Day Open', 'School Day Closed']
      expect(aggregator_results.bucketed_data.keys).to match_array(keys)
      keys.each do |key|
        expect(aggregator_results.bucketed_data[key].any?(:nil?)).to eq false
      end
      expect(aggregator_results.bucketed_data['School Day Open'].first).to eq 520.0
      expect(aggregator_results.bucketed_data_count.keys).to match_array(keys)
    end

    it 'produces the right series names' do
      expect(aggregator_results.series_names).to eq series_names
    end

    it 'populates the x axis' do
      # currently produces 364 days
      expect(aggregator_results.x_axis.size).to eq 7
      expect(aggregator_results.x_axis).to match_array(%w[Sunday Monday Tuesday Wednesday Thursday
                                                          Friday Saturday])
      expect(aggregator_results.x_axis_date_ranges.last).to eq expected_x_axis_end_range
      expect(aggregator_results.x_axis_date_ranges.first).to eq expected_x_axis_start_range
    end

    context 'when moving back one year' do
      let(:timescale) { { up_to_a_year: -1 } }

      it 'populates the x axis' do
        expect(aggregator_results.x_axis.size).to eq 7
        # should end one day before the previous year range
        previous_year_x_axis_end_range = [expected_x_axis_start_date - 1, expected_x_axis_start_date - 1]
        expect(aggregator_results.x_axis_date_ranges.last).to eq previous_year_x_axis_end_range
      end
    end
  end
end
