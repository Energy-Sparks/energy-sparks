module TariffsHelper
  def any_smart_meters?(school)
    school.meters.dcc.any?
  end

  def smart_meter_tariffs(meter)
    smart_meter_tariff_attributes = meter.smart_meter_tariff_attributes
    return [] unless smart_meter_tariff_attributes
    smart_meter_tariff_attributes[:accounting_tariff_generic]
  end
end
