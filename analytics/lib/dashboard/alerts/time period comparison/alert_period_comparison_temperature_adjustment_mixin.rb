# shared code between gas/heat derived classes from electricity
# classes to simulate multiple inheritance
module AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertModelCacheMixin
  attr_reader :total_previous_period_unadjusted_kwh
  attr_reader :total_previous_period_unadjusted_£
  attr_reader :total_previous_period_unadjusted_co2
  attr_reader :previous_period_kwhs_adjusted

  def self.unadjusted_template_variables
    {
      total_previous_period_unadjusted_kwh: {
        description: 'Total kwh in previous period, unadjusted for temperature or length of holiday',
        units:  :kwh,
        benchmark_code: 'uapk'
      },
      total_previous_period_unadjusted_£: {
        description: 'Total cost £ in previous period, unadjusted for temperature or length of holiday',
        units:  :£
      },
      total_previous_period_unadjusted_co2:{
        description: 'Total co2 in previous period, unadjusted for temperature or length of holiday',
        units:  :co2
      }
    }
  end

  private def temperature_adjust; true end

  private def average_current_period_temperature
    @average_current_period_temperature ||= calculate_average_current_period_temperature
  end

  protected def temperature_adjust_kwh(aggregate_meter, previous_date, data_type)
    @model_calc ||= model_calculation(@model_asof_date) # probably already cached
    @previous_kwh_cache ||= {}
    @previous_kwh_cache[previous_date] ||= {}
    return @previous_kwh_cache[previous_date][data_type] if @previous_kwh_cache[previous_date].key?(data_type)

    t_kwh = target_kwh(previous_date, :kwh)

    adjustment_kwh = @model_calc.temperature_compensated_one_day_gas_kwh(previous_date, average_current_period_temperature, t_kwh, 0.0, community_use: community_use)

    adjustment = t_kwh == 0.0 ? 1.0 : adjustment_kwh / t_kwh

    kwh = target_kwh(previous_date, data_type) * adjustment

    @previous_kwh_cache[previous_date][data_type] = kwh
  end

  private def target_kwh(date, data_type)
    aggregate_meter.amr_data.one_day_kwh(date, data_type, community_use: community_use)
  end

  private def model_calculation(asof_date)
    @model_asof_date = asof_date
    @model = model_cache(aggregate_meter, asof_date)
  end

  #
  # compensate previous period daily kWh readings to the average
  # temperature in the current period - only applied for holiday comparison
  # unlike school week comparison where individual Monday to Monday etc. adjustments
  # can be made, holidays have odd combinations of weekdays and lengths
  # of holidays so can't be simplistically matched in the same way,
  # so temperature compensate the previous holiday to the average temperature
  # of the current holiday.
  #
  # As an example if the previous holiday was cold e.g. 0C and the current 10C
  # then the previous year's kWh consumption would need to be reduced for comparison
  # purposes with temperature compensation from 0C to 10C e.g. roughly halving
  # heating gas consumption (plus a less temperature dependent hot water consumption)
  #
  private def calculate_average_current_period_temperature
    current_period, _previous_period = last_two_periods(@asof_date)
    @school.temperatures.average_temperature_in_date_range(current_period.start_date, current_period.end_date)
  end

  def total_previous_period_unadjusted_values(data_type)
    _current_period, previous_period = last_two_periods(@asof_date)
    aggregate_meter.amr_data.kwh_date_range(previous_period.start_date, previous_period.end_date, data_type, community_use: community_use)
  end

  def set_previous_period_unadjusted_kwh_£_co2_variables
    @total_previous_period_unadjusted_kwh = total_previous_period_unadjusted_values(:kwh)
    @total_previous_period_unadjusted_£   = total_previous_period_unadjusted_values(:£)
    @total_previous_period_unadjusted_co2 = total_previous_period_unadjusted_values(:co2)
  end
end
