require_relative 'heating_model_temperature_space_thermal_mass'
require_relative 'shared_manually_configured_multiple_inheritance_code'

module AnalyseHeatingAndHotWater
  # manually configured version of therally heavy model, data held in meter attributes
  class HeatingModelThermalMassingModeTemperatureSpaceManuallyConfigured < HeatingModelTemperatureSpaceThermalMass
    include SharedManuallyConfiguredMultipleInheritanceCode
  end
end
