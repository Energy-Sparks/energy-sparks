require_relative '../utilities/half_hourly_data'
require_relative '../utilities/half_hourly_loader'

# Maintains a schedule of cost data
# Used in parallel to AMRData for a meter
#
# Each day refers to OneDaysCostData instance which holds a series of
# 48 x half hourly costs, plus standing charges
#
# Extended by other classes to adjust logic based on two main categories
# of tariff: economic costs, accounting costs
# economic costs are simpler, just a rate (or 2 if differential) - good for forecasting, education
# accounting costs, contain lots of standing charges
#
# HalfHourlyData
#  CostSchedule
#    EconomicCosts
#      CachingEconomicCosts
#        CachingCurrentEconomicCosts
#    EconomicCostsPrecalculated
#        CurrentEconomicCostsPrecalculated
#    AccountingCosts
#      CachingAccountingCosts
#      AccountingCostsPrecalculated
#
# Sub classes implement:
# costs(date, meter, days_kwh_x48)
# one_days_cost_data(date) => OneDaysCostData
#
# and may override:
# one_day_total_cost(date)
class CostSchedule < HalfHourlyData
  attr_reader :fuel_type, :amr_data

  #This class is initially false but will be set to true at the end
  #of the aggregation process. Indicating that any changes to meter data
  #or costs are completed.
  #
  #Used by sub-classes to change caching behaviour. If aggregation is completed
  #then the sub-classes cache the results of tariff calculations. Before that
  #calculates are done on request.
  attr_accessor :post_aggregation_state

  # Processes the tariff and consumption data for a list of meters, to calculate the
  # combined costs which are them associated with an aggregate meter
  #
  # @param Dashboard::Meter combined_meter the aggregate meter to which the combined costs will be added
  # @param Array list_of_meters the individual meters whose costs and tariffs will be processed
  # @param Date combined_start_date start date of range
  # @param Date combined_end_date end date of range
  # @param Symbol either :economic_tariff or :current_economic_tariff
  # @param cost_schedule a subclass of CostSchedule
  def self.combine_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date, cost_schedule_type, cost_schedule)
    Logging.logger.info "Combining #{cost_schedule_type} from  #{list_of_meters.length} meters from #{combined_start_date} to #{combined_end_date}"

    (combined_start_date..combined_end_date).each do |date|
      list_of_meters_on_date = list_of_meters.select { |m| date >= m.amr_data.start_date && date <= m.amr_data.end_date }

      #If provide block returns true then we'll skip the cost calculation
      #for this date
      next if block_given? && yield(date, list_of_meters_on_date)

      list_of_days_economic_costs = list_of_meters_on_date.map { |m| m.amr_data.send(cost_schedule_type).one_days_cost_data(date) }
      cost_schedule.add(date, OneDaysCostData.combine_costs(list_of_days_economic_costs))
    end
    Logging.logger.info "Created combined cost schedule #{cost_schedule.costs_summary}"
    cost_schedule
  end

  #@param Dashboard::Meter meter the meter whose costs this schedule describes
  def initialize(meter_tariffs, amr_data, fuel_type)
    super(:amr_data_accounting_tariff)
    @meter_tariffs = meter_tariffs
    @amr_data = amr_data
    @fuel_type = fuel_type
    @bill_component_types_internal = Hash.new(nil) # only interested in (quick access) to keys, so maintain as hash rather than array
    @post_aggregation_state = false
  end

  #Return list of all bill component types found across daily cost information
  def bill_component_types
    @bill_component_types_internal.keys
  end

  # Scale the standing charges across the entire range of days
  #
  # See OneDaysCostData#scale_standing_charges
  #
  # used in obscure case where we have split storage heater meter up
  # into storage and not-storage components, artificially split up standing charges
  # proportion by kwh total usage
  def scale_standing_charges(percent)
    (start_date..end_date).each do |date|
      one_days_cost_data(date).scale_standing_charges(percent)
    end
  end

  # See OneDaysCostData#bill_component_costs_per_day
  def bill_component_costs_for_day(date)
    one_days_cost_data(date).bill_component_costs_per_day
  end

  # See OneDaysCostData#one_day_total_cost
  def one_day_total_cost(date)
    one_days_cost_data(date).one_day_total_cost
  end

  # See OneDaysCostData#differential_tariff
  def differential_tariff?(date)
    one_days_cost_data(date).differential_tariff?
  end

  # See OneDaysCostData#costs_x48
  def days_cost_data_x48(date)
    one_days_cost_data(date).costs_x48
  end

  # See OneDaysCostData#costs_x48
  def cost_data_halfhour(date, halfhour_index)
    one_days_cost_data(date).costs_x48[halfhour_index]
  end

  # Provides a breakdown of rates and standing charges at half-hour level.
  #
  # Used for charts series (`series_breakdown: :accounting_cost`)
  #
  # See OneDaysCostData#rates_at_half_hour
  def cost_data_halfhour_broken_down(date, halfhour_index)
    cost_hh_£ = one_days_cost_data(date).rates_at_half_hour(halfhour_index)
    cost_hh_£.merge!(one_days_cost_data(date).standing_charges.transform_values{ |one_day_kwh| one_day_kwh / 48.0 })
    cost_hh_£
  end

  # Calculate the cost for a given date
  #
  # @param Date date the date to calculate. Used to lookup consumption and tariff data
  # @return OneDaysCostData
  public def calculate_tariff_for_date(date)
    raise EnergySparksNotEnoughDataException, "Doing cost calculations for date #{date} meter start_date #{@amr_data.start_date}" if date < @amr_data.start_date
    kwh_x48 = @amr_data.days_kwh_x48(date, :kwh)
    costs(tariff_date(date), kwh_x48)
  end

  #Log summary of costs for a day
  public def costs_summary
    type_info = "with the following bill components: #{bill_component_types}"
    "costs for #{@fuel_type} meter, #{self.length} days from #{start_date} to #{end_date}, £#{total_costs.round(0)} of which standing charges £#{total_standing_charges.round(0)}, #{type_info}"
  end

  #Calculate total cost across the entire date range
  #Possibly unused now?
  public def total_costs
    total_in_period(start_date, end_date)
  end

  #Calculate total for standing charges across entire date range
  private def total_standing_charges
    total_standing_charges_between_dates(start_date, end_date)
  end

  #Calculate total standing charge for a specific period
  #Used in old advice pages
  public def total_standing_charges_between_dates(date1, date2)
    total = 0.0
    (date1..date2).each do |date|
      total += one_days_cost_data(date).total_standing_charge
    end
    total
  end

  #Allows sub-classes to override the date to be used when looking up tariffs
  private def tariff_date(date)
    date
  end

  private def add_to_list_of_bill_component_types(one_day_cost)
    @bill_component_types_internal.merge!(Hash[one_day_cost.bill_components.collect { |type| [type, nil] }])
  end

  #Overrides base class method. Add the cost data for a day
  #
  # @param Date date
  # @param OneDaysCostData costs
  public def add(date, costs)
    set_min_max_date(date)
    add_to_list_of_bill_component_types(costs) unless costs.nil?
    self[date] = costs
  end

  #Has this day already been calculated?
  def calculated?(date)
    !self[date].nil?
  end

  def date_exists?(date)
    !date_missing?(date)
  end

  def date_missing?(date)
    c = one_days_cost_data(date)
    c.nil?
  end

  #Calculate total cost within a specified period
  private def total_in_period(start_date, end_date)
    total = 0.0
    (start_date..end_date).each do |date|
      total += one_day_total_cost(date)
    end
    total
  end

  #Return the cost information for a specific day
  #
  #Implemented by sub-classes to return the tariff information for a given day
  #Allows the subclass to choose whether to return the economic or accounting cost
  #
  # @param Date _date the date for which tariffs should be returned
  # @param Dashboard::Meter meter the meter whose tariff information is to be retrieved
  # @param Array _days_kwh_x48 the consumption to use to calculate costs
  protected def costs(_date, _meter_tariffs, _days_kwh_x48)
    raise EnergySparksAbstractBaseClass.new('Unexpected call to abstract base class for CostSchedule: costs')
  end
end
