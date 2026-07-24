# frozen_string_literal: true

module MeterAttributes
  class BackdateTariff < MeterAttributeTypes::AttributeBase
    id :backdate_tariff
    key :backdate_tariff
    name 'Tariffs > Backdate DCC tariff'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        days: MeterAttributeTypes::Integer.define(
          required: true, hint: 'by default backdates up to 30 days, if you set to 0 then wont backdate'
        )
      }
    )
  end
end
