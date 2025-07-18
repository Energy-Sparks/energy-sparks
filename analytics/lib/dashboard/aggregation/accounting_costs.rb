require_relative './cost_schedule'

class AccountingCosts < CostSchedule
  protected def costs(date, days_kwh_x48)
    @meter_tariffs.accounting_cost(date, days_kwh_x48)
  end

  # Processes the tariff and consumption data for a list of meters, to
  # calculate the combined accounting costs for an aggregate meter
  #
  # If any of the meters are missing tariffs for a date within the period
  # provided, then the cost calculation will be skipped for all meters.
  #
  # @param Dashboard::Meter combined_meter the aggregate meter to which the combined costs will be added
  # @param Array list_of_meters the individual meters whose costs and tariffs will be processed
  # @param Date combined_start_date start date of range
  # @param Date combined_end_date end date of range
  # @return AccountingCostsPrecalculated
  def self.combine_accounting_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date)
    combine_costs_from_multiple_meters(combined_meter, list_of_meters, combined_start_date, combined_end_date, :accounting_tariff, AccountingCostsPrecalculated.new(combined_meter.meter_tariffs, combined_meter.amr_data, combined_meter.fuel_type)) do |date, list_of_meters_on_date|
      missing_accounting_costs = list_of_meters_on_date.select { |m| !m.amr_data.date_exists_by_type?(date, :accounting_cost) }
      missing_accounting_costs.length > 0
    end
  end

  # returns a x48 array of half hourly costs
  def one_days_cost_data(date)
    return calculate_tariff_for_date(date) unless post_aggregation_state
    add(date, calculate_tariff_for_date(date)) unless calculated?(date)
    self[date]
  end

  def one_day_total_cost(date)
    @cache_days_totals[date] = one_days_cost_data(date).one_day_total_cost unless @cache_days_totals.key?(date)
    @cache_days_totals[date]
  end
end

class CachingAccountingCosts < AccountingCosts
  # returns a x48 array of half hourly costs, only caches post aggregation, and front end cache
  def one_days_cost_data(date)
    return calculate_tariff_for_date(date) unless post_aggregation_state
    add(date, calculate_tariff_for_date(date)) unless calculated?(date)
    self[date]
  end

  # in the case of parameterised accounting costs, the underlying costs types are not known
  # until post aggregation, on the first request for chart bucket names which is before
  # data requests get made which build up the component list, so manually instantiate the list
  # on the fly; quicker alternative would be to search through the static tariff data through time (meter_tariffs)
  def bill_component_types
    create_all_bill_components(amr_data.start_date, amr_data.end_date) if post_aggregation_state && @bill_component_types_internal.empty?
    @bill_component_types_internal.keys
  end

  # also instantiates all accounting data in pre aggregated form
  private def create_all_bill_components(start_date, end_date)
    (start_date..end_date).each do |date|
      one_day_total_cost(date)
    end
  end

end

class AccountingCostsPrecalculated < AccountingCosts
  # always precalculated so don't calculate on the fly
  def one_days_cost_data(date)
    self[date]
  end
end
