module TariffsHelper
  def user_tariff_charge_types
    UserTariffCharge::CHARGE_TYPES.keys.map {|k| [k.to_s.humanize, k]}
  end

  def user_tariff_charge_type_units
    UserTariffCharge::CHARGE_TYPE_UNITS.map {|k, v| [v, k]}
  end

  def user_tariff_charge_type_humanized(charge_type)
    charge_type.humanize
  end

  def user_tariff_charge_type_units_humanized(charge_type_units)
    UserTariffCharge::CHARGE_TYPE_UNITS[charge_type_units.to_sym]
  end

  def user_tariff_charge_type_units_as_json
    UserTariffCharge::CHARGE_TYPES.to_json
  end
end
