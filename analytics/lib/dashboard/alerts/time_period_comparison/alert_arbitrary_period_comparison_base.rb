require_relative 'alert_holiday_comparison_base'

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
