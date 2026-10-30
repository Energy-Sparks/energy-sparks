require_relative './alert_period_comparison_gas_mixin.rb'
require_relative './alert_period_comparison_temperature_adjustment_mixin.rb'

class AlertArbitraryPeriodComparisonBase < AlertHolidayComparisonBase
  def initialize(school, type = :arbitrarycomparison)
    super(school, type)
  end

  private   def period_type;        'arbitrary period'          end
  protected def period_name(period); comparison_configuration[:name] end
  private def calculate_time_of_year_relevance(asof_date)
    return 10.0 if asof_date >= @current_period.end_date
    return  5.0 if asof_date >= @current_period.start_date
    0.0
  end

  def timescale
    "custom"
  end
end

class AlertArbitraryPeriodComparisonElectricityBase < AlertArbitraryPeriodComparisonBase
  def fuel_type; :electricity end

  def self.template_variables
    specific = { 'Change in between last 2 periods' => dynamic_template_variables(:electricity) }
    specific.merge(superclass.template_variables)
  end
end

class AlertArbitraryPeriodComparisonGasBase < AlertArbitraryPeriodComparisonBase
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertPeriodComparisonGasMixin

  def self.template_variables
    AlertPeriodComparisonGasMixin.template_variables.merge(superclass.template_variables)
  end

  def fuel_type; :gas end
end

class AlertArbitraryPeriodComparisonStorageHeaterBase < AlertArbitraryPeriodComparisonBase
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertPeriodComparisonGasMixin
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin

  def self.template_variables
    AlertPeriodComparisonGasMixin.template_variables.merge(superclass.template_variables)
  end

  def fuel_type; :electricity end
end
