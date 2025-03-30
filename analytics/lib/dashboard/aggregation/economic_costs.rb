class EconomicCosts < CostSchedule
  protected def costs(date, days_kwh_x48)
    @meter_tariffs.economic_cost(date, days_kwh_x48)
  end

  # Processes the tariff and consumption data for a list of meters, to
  # calculate the combined economic costs for an aggregate meter
  #
  # @param Dashboard::Meter combined_meter the aggregate meter to which the combined costs will be added
  # @param Array list_of_meters the individual meters whose costs and tariffs will be processed
  # @param Date combined_start_date start date of range
  # @param Date combined_end_date end date of range
  # @return EconomicCostsPrecalculated
  def self.combine_economic_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date)
    combine_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date, :economic_tariff, EconomicCostsPrecalculated.new(combined_meter.meter_tariffs, combined_meter.amr_data, combined_meter.fuel_type))
  end

  # Processes the tariff and consumption data for a list of meters, to
  # calculate the combined current economic costs for an aggregate meter
  #
  # @param Dashboard::Meter combined_meter the aggregate meter to which the combined costs will be added
  # @param Array list_of_meters the individual meters whose costs and tariffs will be processed
  # @param Date combined_start_date start date of range
  # @param Date combined_end_date end date of range
  # @return CurrentEconomicCostsPrecalculated
  def self.combine_current_economic_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date)
    combine_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date, :current_economic_tariff, CurrentEconomicCostsPrecalculated.new(combined_meter.meter_tariffs, combined_meter.amr_data, combined_meter.fuel_type))
  end
end

# Extends base class to implement caching of calculated costs.
#
# Pre-aggregation the costs are always calculated on demand. And are not added to the
# time series of costs maintained by the class. After aggregation they are calculated
# and stored. So the series is calculated and built on demand.
#
# "parameterised representation of economic costs until after agggregation to reduce memory footprint"
class CachingEconomicCosts < EconomicCosts
  # Returns the costs for a specific date
  # @param Date date
  # @return OneDaysCostData
  def one_days_cost_data(date)
    return calculate_tariff_for_date(date) unless post_aggregation_state
    add(date, calculate_tariff_for_date(date)) unless calculated?(date)
    self[date]
  end

  #Return total cost for a day.
  #See OneDaysCostData#one_day_total_cost
  #
  #Caches results, regardless of aggregation state
  def one_day_total_cost(date)
    @cache_days_totals[date] = one_days_cost_data(date).one_day_total_cost unless @cache_days_totals.key?(date)
    @cache_days_totals[date]
  end
end

# Extends the default economic costs class to force calculations to always
# use the tariff data for the latest meter date.
class CachingCurrentEconomicCosts < CachingEconomicCosts
  # for current economic tariffs, don't use time varying tariffs
  # but use the most recent tariff
  #
  # slightly problematic for testing if asof_date changed as
  # will only use latest tariff not asof_date tariff,
  # perhaps use an '@@asof_date || end_date' to pass down this far?
  #
  private def tariff_date(_date)
    @amr_data.end_date
  end
end

# This implementation relies on the one_days_cost_data having been explicitly
# added to the schedule of data (via +add+), rather than being calculated (and possibly cached)
# on the fly. It's used where we are creating a schedule of costs for a combined
# meter and there are a variety of tariffs used by the underlying meters. Reduces
# the calculation overheads.
class EconomicCostsPrecalculated < EconomicCosts

  #Return total cost for a day.
  #See OneDaysCostData#one_day_total_cost
  #
  #Caches results, regardless of aggregation state
  def one_day_total_cost(date)
    @cache_days_totals[date] = one_days_cost_data(date).one_day_total_cost unless @cache_days_totals.key?(date)
    @cache_days_totals[date]
  end

  # Returns the costs for a specific date
  # Relies on costs having been pre-calculated and added to the schedule
  def one_days_cost_data(date)
    self[date]
  end

end

class CurrentEconomicCostsPrecalculated < EconomicCostsPrecalculated
end
