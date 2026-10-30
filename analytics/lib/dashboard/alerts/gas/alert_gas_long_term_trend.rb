require_relative '../common/alert_long_term_trend'

class AlertGasLongTermTrend < AlertLongTermTrend
  include Logging
  def self.template_variables
    specific = { 'Gas long term trend' => long_term_variables('gas')}
    specific.merge(self.superclass.template_variables)
  end

  def fuel_type
    :gas
  end

  def aggregate_meter
    @school.aggregated_heat_meters
  end

  def temperature_compensation_factor
    scalar = CalculateAggregateValues.new(@school)

    # aggregate to get dates - inefficient
    y0 = scalar.scalar({ year:   0 }, fuel_type, :£,  { asof_date: @asof_date})
    y1 = scalar.scalar({ year:  -1 }, fuel_type, :£,  { asof_date: @asof_date})

    @degreedays_this_year = @school.temperatures.degree_days_in_date_range(y0[:start_date], y0[:end_date])
    @degreedays_last_year = @school.temperatures.degree_days_in_date_range(y1[:start_date], y1[:end_date])

    @degreeday_adjustment = @degreedays_this_year / @degreedays_last_year
  rescue EnergySparksNotEnoughDataException => e
    logger.info "Model failed: e.message"
    1.0
  end
end
