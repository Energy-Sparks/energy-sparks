module TariffsHelper
  def user_tariff_title(user_tariff)
    "#{user_tariff.name} #{user_tariff.fuel_type} for #{user_tariff.start_date.to_s(:es_compact)} to #{user_tariff.end_date.to_s(:es_compact)}"
  end

  def user_tariff_charge_types
    UserTariffCharge::CHARGE_TYPES.keys.map {|k| [k.to_s.humanize, k]}
  end

  def user_tariff_charge_type_units
    UserTariffCharge::CHARGE_TYPE_UNITS.map {|k, v| [v, k]}
  end

  def user_tariff_charge_for_type(user_tariff_charges, charge_type)
    user_tariff_charges.find { |c| c.charge_type.to_s == charge_type.to_s } || UserTariffCharge.new(charge_type: charge_type)
  end

  def user_tariff_charge_type_units_for(charge_type)
    UserTariffCharge::CHARGE_TYPES[charge_type][:units].map { |k| [UserTariffCharge::CHARGE_TYPE_UNITS[k], k] }
  rescue
    []
  end

  def user_tariff_charge_type_humanized(charge_type)
    charge_type.to_s.humanize
  end

  def user_tariff_charge_type_units_humanized(charge_type_units)
    UserTariffCharge::CHARGE_TYPE_UNITS[charge_type_units.to_sym]
  end

  def user_tariff_charge_type_units_as_json
    UserTariffCharge::CHARGE_TYPES.to_json
  end

  def user_tariff_charge_type_description(charge_type)
    charge_type.to_s.humanize
  end
end
