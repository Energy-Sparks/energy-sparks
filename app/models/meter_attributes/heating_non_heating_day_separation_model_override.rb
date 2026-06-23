# frozen_string_literal: true

module MeterAttributes
  class HeatingNonHeatingDaySeparationModelOverride < MeterAttributeTypes::AttributeBase
    id  :heating_non_heating_day_separation_model_override
    key :heating_non_heating_day_separation_model_override
    name 'Heating > Heating/Non-Heating Separation Model Override'

    structure MeterAttributeTypes::Symbol.define(
      required: true,
      allowed_values: %i[fixed_single_value_temperature_sensitive_regression_model
                         temperature_sensitive_regression_model temperature_sensitive_regression_model_covid_tolerant
                         no_idea either not_enough_data]
    )
  end
end
