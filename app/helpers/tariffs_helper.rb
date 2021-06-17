module TariffsHelper
  def charge_type_humanized(charge_type)
    UserTariffCharge::CHARGE_TYPES[charge_type.to_sym]
  end

  def charge_type_units_humanized(charge_type_units)
    UserTariffCharge::CHARGE_TYPE_UNITS[charge_type_units.to_sym]
  end
end
