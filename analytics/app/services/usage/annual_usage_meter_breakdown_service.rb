# frozen_string_literal: true

module Usage
  class AnnualUsageMeterBreakdownService
    include AnalysableMixin

    DAYS_OF_DATA_REQUIRED = 7

    # Create a service capable of calculating the annual energy usage for all
    # meters in a school, for the last 12 months
    #
    # To calculate usage for a whole school provide the aggregate electricity
    # meter as the parameter.
    #
    # @param [MeterCollection] meter_collection the school to be analysed
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if the schools doesnt have meters of the specified type
    def initialize(meter_collection, fuel_type, asof_date = Date.today)
      @meter_collection = meter_collection
      @fuel_type = fuel_type
      @asof_date = asof_date
      validate_meter_collection
    end

    def enough_data?
      meter_data_checker.at_least_x_days_data(DAYS_OF_DATA_REQUIRED)
    end

    def data_available_from
      meter_data_checker.date_when_enough_data_available(DAYS_OF_DATA_REQUIRED)
    end

    def calculate_breakdown
      meter_breakdown = calculate
      total_kwh = total_kwh(meter_breakdown)
      add_percentages(meter_breakdown, total_kwh)
      AnnualUsageMeterBreakdown.new(
        meter_breakdown: meter_breakdown,
        percentage_change_last_year: annual_percent_kwh_change(aggregate_meter, total_kwh),
        start_date: start_date,
        end_date: end_date
      )
    end

    private

    def total_kwh(meter_breakdown)
      meter_breakdown.map { |_meter, usage| usage[:usage].kwh || 0.0 }.sum
    end

    def add_percentages(meter_breakdown, total_kwh)
      meter_breakdown.each_value do |usage|
        usage[:usage].percent = usage[:usage].kwh / total_kwh
      end
    end

    def calculate
      underlying_meters.each_with_object({}) do |meter, breakdown|
        meter_start_date = [start_date, meter.amr_data.start_date].max
        meter_end_date   = [end_date,   meter.amr_data.end_date].min
        if meter_end_date < meter_start_date
          nil # 'retired' meter before aggregate start date
        else
          breakdown[meter.mpan_mprn] = calculate_meter_breakdown(meter, meter_start_date, meter_end_date)
        end
      end
    end

    def calculate_meter_breakdown(meter, start_date, end_date)
      this_year_kwh = meter.amr_data.kwh_date_range(start_date, end_date, :kwh)
      {
        name: meter.analytics_name,
        usage: CombinedUsageMetric.new(
          kwh: this_year_kwh,
          £: meter.amr_data.kwh_date_range(start_date, end_date, :£),
          co2: meter.amr_data.kwh_date_range(start_date, end_date, :co2)
        ),
        annual_change: annual_percent_kwh_change(meter, this_year_kwh)
      }
    end

    def annual_percent_kwh_change(meter, this_year_kwh)
      this_year_start_date     = end_date - 363 # 52 weeks
      previous_year_end_date   = this_year_start_date - 1
      previous_year_start_date = previous_year_end_date - 363 # 52 weeks

      # calculate annual change but only if aggregate and individual meter cover whole of previous year
      return nil unless aggregate_meter.amr_data.start_date <= previous_year_start_date

      whole_meter_this_year     = whole_meter_in_range(meter, this_year_start_date, end_date)
      whole_meter_previous_year = whole_meter_in_range(meter, previous_year_start_date, previous_year_end_date)

      return unless whole_meter_this_year && whole_meter_previous_year

      previous_year_kwh = meter.amr_data.kwh_date_range(previous_year_start_date, previous_year_end_date, :kwh)
      percent_change(this_year_kwh, previous_year_kwh)
    end

    def whole_meter_in_range(meter, start_date, end_date)
      meter.amr_data.start_date <= start_date && meter.amr_data.end_date >= end_date
    end

    def percent_change(this_year_kwh, previous_year_kwh)
      return nil if previous_year_kwh.zero?

      (this_year_kwh - previous_year_kwh) / previous_year_kwh
    end

    def start_date
      @start_date ||= chart_date_ranges[:start_date]
    end

    def end_date
      @end_date ||= chart_date_ranges[:end_date]
    end

    # The original advice page produced a usage breakdown table that was shown next
    # to a chart. So the date ranges used to calculate the usage breakdown were aligned
    # to those in the chart.
    #
    # Due to how that chart is generated (a weekly breakdown, with ranges aligned to Sunday-Saturday),
    # the start and end dates aren't just the latest meter data minus 12 months
    #
    # Rather than run the chart to just pull out the date ranges, this method calls the
    # charting code responsible for building the series ranges. It supplies the same
    # chart config, for consistency.
    #
    # This means the code is consistent with the chart, but if we want a service that just
    # generates a usage breakdown based on the last 12 months, then we'll need to tweak the
    # code and use aggregate_meter.amr_date.end_date instead
    def chart_date_ranges
      # create a period calculator, to calculate date ranges
      period_calculator = PeriodsBase.period_factory(chart_config,
                                                     @meter_collection,
                                                     aggregate_meter.amr_data.start_date,
                                                     aggregate_meter.amr_data.end_date)

      # calculate the ranges
      periods = period_calculator.periods
      # construct a bucketor that can create the x-axis from those ranges
      # will be a XBucketWeek based on current chart config
      bucketor = XBucketBase.create_bucketor(chart_config[:x_axis], periods)
      # populate the axis and then read off the start and end of the ranges
      bucketor.create_x_axis
      { start_date: bucketor.x_axis_bucket_date_ranges.first.first, end_date: bucketor.x_axis_bucket_date_ranges.last.last }
    end

    # Load the chart config required to calculate the start/end dates for the
    # analysis
    def chart_config
      @chart_config ||= ChartManager.new(@meter_collection).get_chart_config(chart_for_fuel_type)
    end

    # Chart that was originally displayed next to this breakdown
    def chart_for_fuel_type
      if @fuel_type == :electricity
        :group_by_week_electricity_meter_breakdown_one_year
      else
        :group_by_week_gas_meter_breakdown_one_year
      end
    end

    def aggregate_meter
      @meter_collection.aggregate_meter(@fuel_type)
    end

    def underlying_meters
      case @fuel_type
      when :electricity
        @meter_collection.electricity_meters
      when :gas
        @meter_collection.heat_meters
      end
    end

    def meter_data_checker
      @meter_data_checker ||= Util::MeterDateRangeChecker(aggregate_meter, @asof_date)
    end

    def validate_meter_collection
      meters = underlying_meters
      raise EnergySparksUnexpectedStateException, 'Unexpected fuel type' if meters.nil?
      raise EnergySparksUnexpectedStateException, "School does not have #{fuel_type} meters" if meters.empty?
    end
  end
end
