# holds and calculates a schedule of carbon emissions - matches amd_data so [date] = [48x carbon emissions]

class CarbonEmissions < HalfHourlyData
  attr_reader :grid_carbon_schedule, :flat_rate, :meter_id, :amr_data
  def initialize(meter_id_for_debug, flat_rate = nil, grid_carbon_schedule = nil, amr_data = nil)
    super(:carbon_emissions)
    @meter_id = meter_id_for_debug
    @flat_rate = flat_rate
    @grid_carbon_schedule = grid_carbon_schedule
    @amr_data = amr_data
  end

  def self.create_carbon_emissions(meter_id_for_debug, amr_data, flat_rate, grid_carbon_schedule)
    CarbonEmissionsParameterised.new(meter_id_for_debug, flat_rate, grid_carbon_schedule, amr_data)
  end

  def self.combine_carbon_emissions_from_multiple_meters(combined_meter_id, list_of_meters, combined_start_date, combined_end_date)
    Logging.logger.info "Combining carbon emissions from  #{list_of_meters.length} meters from #{combined_start_date} to #{combined_end_date}"

    combined_carbon_emissions = CarbonEmissionsPreAggregated.new(combined_meter_id)

    (combined_start_date..combined_end_date).each do |date|
      combined_carbon_emissions.add(date, combined_one_days_carbon_emissions_x48(date, meter))
    end

    Logging.logger.info "Created combined meter emissions #{combined_carbon_emissions.emissions_summary}"
    combined_carbon_emissions
  end

  private_class_method def self.combined_one_days_carbon_emissions_x48(date, meter)
    list_of_meters_on_date = list_of_meters.select { |meter| meter.amr_data.date_exists?(date) }
    list_of_days_carbon_emissions = list_of_meters_on_date.map { |meter| meter.amr_data.carbon_emissions.one_days_data_x48(date) }
    AMRData.fast_add_multiple_x48_x_x48(list_of_days_carbon_emissions)
  end

  private def emissions_for_date(date, amr_data, flat_rate, grid_carbon)
    kwh_x48 = kwh_x48_data_for_date_checked(date, amr_data)
    calculate_emissions_for_date(date, kwh_x48, flat_rate, grid_carbon)
  end

  private def calculate_emissions_for_date(date, kwh_x48, flat_rate, grid_carbon)
    if flat_rate.nil?
      AMRData.fast_multiply_x48_x_x48(kwh_x48, grid_carbon.one_days_data_x48(date))
    else
      AMRData.fast_multiply_x48_x_scalar(kwh_x48, flat_rate)
    end
  end

  private def kwh_x48_data_for_date_checked(date, amr_data)
    if amr_data.date_missing?(date) # TODO(PH, 7Apr2019) - bad Castle data for 1 day in 2009, work out why validation not cleaning up
      logger.warn "Warning: missing amr data for #{date} using zero"
      Array.new(48, 0.0)
    else
      amr_data.days_kwh_x48(date, :kwh)
    end
  end

  def co2_data_halfhour(date, halfhour_index)
    one_days_data_x48(date)[halfhour_index]
  end
end

# parameterised version of carbon emissions object which only
# caches data after the aggregation service has completed, dynamically during chart calculations
class CarbonEmissionsParameterised < CarbonEmissions
  attr_accessor :post_aggregation_state
  def initialize(meter_id_for_debug, flat_rate, grid_carbon_schedule, amr_data)
    super(meter_id_for_debug, flat_rate, grid_carbon_schedule, amr_data)
    @post_aggregation_state = false
  end

  def one_days_data_x48(date)
    return calc_emissions_x48(date) unless post_aggregation_state
    add(date, calc_emissions_x48(date)) if date_missing?(date) # cache results post aggregation/cache
    self[date]
  end

  private def calc_emissions_x48(date)
    calculate_emissions_for_date(date, amr_data.days_kwh_x48(date), flat_rate, grid_carbon_schedule)
  end

  # faster than underlying HaldHoutlData version which does more checks
  def one_day_total(date)
    @cache_days_totals[date] = one_days_data_x48(date).sum unless @cache_days_totals.key?(date)
    @cache_days_totals[date]
  end
end

# pre-aggregated carbon emissions; required for solar PV where
# underlying components non linear e.g. mains consumed electric at 280g/kWh, solar at 0g/kWh
# essentially uses default underlying infrastructure, but subclassed to
# improve clarity for debugging
class CarbonEmissionsPreAggregated < CarbonEmissions
end
