module Alerts
  class RelevantAlertTypes
    def initialize(school)
      @school = school
    end

    def list
      alert_types = AlertType.enabled.no_fuel
      alert_types |= AlertType.enabled.electricity_fuel_type if @school.has_electricity?
      alert_types |= AlertType.enabled.gas_fuel_type if @school.has_gas?
      alert_types |= AlertType.enabled.storage_heater_fuel_type if @school.has_storage_heaters?
      alert_types |= AlertType.enabled.solar_pv_fuel_type if @school.has_solar_pv?
      alert_types
    end
  end
end
