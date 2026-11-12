require_relative '../common/alert_long_term_trend'

class AlertElectricityLongTermTrend < AlertLongTermTrend
  def self.template_variables
    specific = { 'Electricity long term trend' => long_term_variables('electricity')}
    specific.merge(self.superclass.template_variables)
  end

  def fuel_type
    :electricity
  end

  def temperature_compensation_factor
    1.0
  end

  def aggregate_meter
    @school.aggregated_electricity_meters
  end
end
