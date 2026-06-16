# frozen_string_literal: true

module MeterAttributes
  class HeatingModel < MeterAttributeTypes::AttributeBase
    id :heating_model
    key :heating_model
    name 'Heating > Heating model'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        max_summer_daily_heating_kwh: MeterAttributeTypes::Integer.define(required: true),
        fitting: MeterAttributeTypes::Hash.define(
          required: false,
          structure: {
            fit_model_start_date: MeterAttributeTypes::Date.define,
            fit_model_end_date: MeterAttributeTypes::Date.define,
            expiry_date_of_override: MeterAttributeTypes::Date.define,
            use_dates_for_model_validation: MeterAttributeTypes::Boolean.define
          }
        )
      }
    )
  end
end
