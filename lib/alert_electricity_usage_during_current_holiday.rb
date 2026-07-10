# frozen_string_literal: true

class AlertElectricityUsageDuringCurrentHoliday < Alerts::UsageDuringCurrentHolidayBase
  def initialize(school)
    super(school, :holiday_electricity_usage_to_date)
  end

  def aggregate_meter
    @school.aggregated_electricity_meters
  end

  def fuel_type
    :electricity
  end

  protected

  def needs_gas_data?
    false
  end
end
