# frozen_string_literal: true

module Usage
  # Calculates a breakdown of school consumption, broken down into a set of usage
  # categories that cover school day open, closed, weekends, holidays and
  # community usage.
  #
  # Uses up to a years worth of data to perform calculations.
  #
  # Note: if a school has less than a years worth of data then the results
  # produced by this service are not suitable for benchmarking, as our
  # benchmarks are based on average consumption across a year.
  class UsageBreakdownService
    include AnalysableMixin

    # Configures how community use times are included in the breakdown
    # filter: :all means all school day periods are returned
    # aggregate: :community_use means all community use consumption is returned as single aggregate value
    COMMUNITY_USE_BREAKDOWN = { filter: :all, aggregate: :community_use }.freeze

    MINIMUM_DAYS_DATA = 7 # minimum data required to run calculations
    YEAR_PERIOD = 52 * 7 - 1

    def initialize(meter_collection:, fuel_type: :electricity, asof_date: Date.today)
      raise 'Invalid fuel type' unless %i[electricity gas storage_heater].include? fuel_type

      @meter_collection = meter_collection
      @fuel_type = fuel_type
      @asof_date = asof_date
    end

    def enough_data?
      meter_date_range_checker.at_least_x_days_data?(MINIMUM_DAYS_DATA)
    end

    def data_available_from
      meter_date_range_checker.date_when_enough_data_available(MINIMUM_DAYS_DATA)
    end

    # Calculates just the kwh consumed out of hours. "Out of hours" is defined
    # as any period when the school is closed. This includes periods of community use.
    #
    # @return Hash
    def out_of_hours_kwh
      build_usage_category_usage_metrics
      calculate_metrics(:kwh)
      { out_of_hours: @out_of_hours.kwh, total: total_kwh }
    end

    # Calculates a the total usage for up to a full years worth of data.
    # Usage is broken down into categories as defined by +OpenCloseTime+, e.g.
    # school day open, closed, weekends, holidays and community use.
    #
    # Usage may be zero for some categories because they don't occur during the
    # period of available data.
    #
    # Costs are based on the tariffs in use at the time of consumption.
    #
    # @return [Usage::UsageBreakdown] the calculated breakdown
    def usage_breakdown
      raise 'Not enough data: at least one week of meter data is required' unless enough_data?

      calculate_usage_breakdown
    end

    private

    def meter_date_range_checker
      @meter_date_range_checker ||= ::Util::MeterDateRangeChecker.new(aggregate_meter, @asof_date)
    end

    def aggregate_meter
      @aggregate_meter ||= case @fuel_type
                           when :electricity then @meter_collection.aggregated_electricity_meters
                           when :gas then @meter_collection.aggregated_heat_meters
                           when :storage_heater then @meter_collection.storage_heater_meter
                           end
    end

    def calculate_usage_breakdown
      build_usage_category_usage_metrics
      calculate_metrics(:kwh)
      calculate_metrics(:£)
      calculate_metrics(:co2)
      calculate_percent
      build_usage_category_breakdown
    end

    def build_usage_category_usage_metrics
      @holiday = CombinedUsageMetric.new
      @school_day_closed = CombinedUsageMetric.new
      @school_day_open = CombinedUsageMetric.new
      @out_of_hours = CombinedUsageMetric.new
      @weekend = CombinedUsageMetric.new
      @community = CombinedUsageMetric.new
      @metrics = {
        OpenCloseTime::HOLIDAY => @holiday,
        OpenCloseTime::WEEKEND => @weekend,
        OpenCloseTime::SCHOOL_OPEN => @school_day_open,
        OpenCloseTime::SCHOOL_CLOSED => @school_day_closed,
        OpenCloseTime::COMMUNITY => @community
      }
    end

    def build_usage_category_breakdown
      @build_usage_category_breakdown ||= Usage::UsageBreakdown.new(
        holiday: @holiday,
        school_day_closed: @school_day_closed,
        school_day_open: @school_day_open,
        weekend: @weekend,
        out_of_hours: @out_of_hours,
        community: @community,
        fuel_type: @fuel_type
      )
    end

    # Calculate the consumption value for each unit (:kwh, :£, co2) for each
    # of the usage categories. Uses public send to update instance variables
    # for each type of unit
    #
    # Updates out of hours usage to be usage except for period when school open
    def calculate_metrics(unit = :kwh)
      day_type_breakdown = calculate_breakdown(unit)
      assign_method_name = "#{unit}="
      @metrics.each do |category, metric|
        metric.public_send(assign_method_name, day_type_breakdown[category] || 0.0)
      end
      out_of_hours = @metrics.values.map(&unit).sum - @school_day_open.public_send(unit)
      @out_of_hours.public_send(assign_method_name, out_of_hours)
    end

    def calculate_percent
      @holiday.percent = @holiday.kwh / total_kwh
      @weekend.percent = @weekend.kwh / total_kwh
      @school_day_open.percent = @school_day_open.kwh / total_kwh
      @school_day_closed.percent = @school_day_closed.kwh / total_kwh
      @community.percent = @community.kwh / total_kwh
      @out_of_hours.percent = @holiday.percent + @weekend.percent + @school_day_closed.percent + @community.percent
    end

    # Initialise a hash with the usage categories for this school
    def initial_breakdown
      Hash[@meter_collection.open_close_times.time_types.map { |type| [type, 0.0] }]
    end

    # Calculate usage for up to a years worth (52 weeks) of data, or whatever is
    # available
    def period_start_date
      [aggregate_meter.amr_data.end_date - YEAR_PERIOD, aggregate_meter.amr_data.start_date].max
    end

    # Calculate the total consumption for a specific unit across the year
    def calculate_breakdown(unit = :kwh)
      total_breakdown = initial_breakdown
      (period_start_date..aggregate_meter.amr_data.end_date).each do |date|
        breakdown = aggregate_meter.amr_data.one_day_kwh(date, unit, community_use: COMMUNITY_USE_BREAKDOWN)
        total_breakdown.merge!(breakdown) do |_category, old_val, new_val|
          old_val + new_val
        end
      end
      total_breakdown
    end

    def total_kwh
      @metrics.values.map(&:kwh).sum
    end
  end
end
