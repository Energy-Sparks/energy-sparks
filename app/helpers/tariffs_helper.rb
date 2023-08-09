module TariffsHelper
  def any_smart_meters?(school)
    school.meters.dcc.any?
  end

  #find all of the economic tariffs for a specific group, collecting them
  #via their scope
  def economic_tariffs_for_school(school)
    {
      school: convert_meter_attributes_to_hash(school.pseudo_meter_attributes),
      school_group: convert_meter_attributes_to_hash(school.school_group_pseudo_meter_attributes),
      global: convert_meter_attributes_to_hash(school.global_pseudo_meter_attributes)
    }
  end

  #convert the meter attributes to a hash, to make them easier to process
  def convert_meter_attributes_to_hash(meter_attributes)
    meter_attributes.inject({}) do |collection, (meter_type, attributes)|
      if include_attribute?(meter_type, attributes)
        collection[meter_type.to_sym] = MeterAttribute.to_analytics(attributes)
      end
      collection
    end
  end

  #ignore meter attributes that aren't for gas or electricity meters
  #ignore those that aren't economic tariffs
  def include_attribute?(meter_type, attributes)
    return false unless [:aggregated_gas, :aggregated_electricity].include?(meter_type.to_sym)
    [:economic_tariff, :economic_tariff_change_over_time].include? attributes[0].attribute_type.to_sym
  end

  def smart_meter_tariffs(meter)
    smart_meter_tariff_attributes = meter.smart_meter_tariff_attributes
    return [] unless smart_meter_tariff_attributes
    smart_meter_tariff_attributes[:accounting_tariff_generic]
  end

  #This isnt ideal, but ensures we're using same approach as analytics
  def rates_for_differential_tariff(tariff_price)
    smart_meter_tariff_attributes = tariff_price.meter.smart_meter_tariff_attributes
    rates = {}
    return rates unless smart_meter_tariff_attributes
    smart_meter_tariff_attributes[:accounting_tariff_generic].each do |tariff|
      if tariff[:start_date] == tariff_price.tariff_date
        rates = tariff[:rates].reject { |k| k == :standing_charge }
      end
    end
    rates
  end
end
