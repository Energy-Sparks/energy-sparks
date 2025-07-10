# frozen_string_literal: true

class SolarPVPanels
  MAINS_ELECTRICITY_CONSUMPTION_INCLUDING_ONSITE_PV = 'Electricity consumed including onsite solar pv consumption'
  SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME = 'Electricity consumed from solar pv'
  SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME = 'Exported solar electricity (not consumed onsite)'
  ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME = 'Electricity consumed from mains'
  SOLAR_PV_PRODUCTION_METER_NAME = 'Solar PV Production'

  SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME_I18N_KEY = 'electricity_consumed_from_solar_pv'
  SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME_I18N_KEY = 'exported_solar_electricity'
  ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME_I18N_KEY = 'electricity_consumed_from_mains'

  SUBMETER_TYPES = [
    ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME,
    SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
    SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME
  ]
end
