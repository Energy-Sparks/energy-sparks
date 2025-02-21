require_relative './alert_schoolweek_comparison_electricity.rb'
require_relative './alert_schoolweek_comparison_gas.rb'
require_relative './alert_previous_holiday_comparison_electricity.rb'
require_relative './alert_previous_holiday_comparison_gas.rb'
require_relative './alert_previous_year_holiday_comparison_electricity.rb'
require_relative './alert_previous_year_holiday_comparison_gas.rb'

module AlertCommunityUseMixin
  def initialize(school, type = self.class.name.to_sym)
    super
    calculate_relevance
  end

  def calculate_relevance
    @relevance = (@relevance == :relevant && @school.community_usage?) ? :relevant : :never_relevant
  end

  protected def community_use
    { filter: :community_only, aggregate: :all_to_single_value }
  end
end

class AlertCommunitySchoolWeekComparisonElectricity < AlertSchoolWeekComparisonElectricity
  include AlertCommunityUseMixin
end

class AlertCommunitySchoolWeekComparisonGas < AlertSchoolWeekComparisonGas
  include AlertCommunityUseMixin
  def adjusted_temperature_comparison_chart
    :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_adjusted_community_only
  end

  def unadjusted_temperature_comparison_chart
    :schoolweek_alert_2_week_comparison_for_internal_calculation_gas_unadjusted_community_only
  end
end

class AlertCommunityPreviousHolidayComparisonElectricity < AlertPreviousHolidayComparisonElectricity
  include AlertCommunityUseMixin
end

class AlertCommunityPreviousHolidayComparisonGas < AlertPreviousHolidayComparisonGas
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertCommunityUseMixin
end

class AlertCommunityPreviousYearHolidayComparisonElectricity < AlertPreviousYearHolidayComparisonElectricity
  include AlertCommunityUseMixin
end

class AlertCommunityPreviousYearHolidayComparisonGas < AlertPreviousYearHolidayComparisonGas
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertCommunityUseMixin
end
