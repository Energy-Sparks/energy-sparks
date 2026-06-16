# frozen_string_literal: true

module MeterAttributes
  class HeatingNonHeatingDayFixedkWh < MeterAttributeTypes::AttributeBase
    id  :heating_non_heating_day_fixed_kwh_separation
    key :heating_non_heating_day_fixed_kwh_separation
    name 'Heating > Heating/Non-Heating Separation Model Fixed Separation in kWh'
    structure MeterAttributeTypes::Float.define(required: true, hint: 'kwh per day')
  end
end
