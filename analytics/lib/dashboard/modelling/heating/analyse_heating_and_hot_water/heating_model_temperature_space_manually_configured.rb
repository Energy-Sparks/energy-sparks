require_relative 'heating_model_temperature_space'
require_relative 'shared_manually_configured_multiple_inheritance_code'

module AnalyseHeatingAndHotWater
  # manually configured version of simple model, data held in meter attributes
  class HeatingModelTemperatureSpaceManuallyConfigured < HeatingModelTemperatureSpace
    include SharedManuallyConfiguredMultipleInheritanceCode
  end
end
