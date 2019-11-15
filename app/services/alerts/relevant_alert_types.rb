module Alerts
  class RelevantAlertTypes
    def initialize(school)
      @school = school
    end

    def list
      alert_types = AlertType.no_fuel
      alert_types = alert_types | AlertType.electricity_fuel_type if @school.has_electricity?
      alert_types = alert_types | AlertType.gas_fuel_type if @school.has_gas?
      alert_types = alert_types | AlertType.storage_heater_fuel_type if @school.has_storage_heaters?
      alert_types = alert_types | AlertType.solar_pv_fuel_type if @school.has_solar_pv?
      alert_types
    end
  end
end
