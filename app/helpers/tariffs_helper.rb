module TariffsHelper
  def user_tariff_title(user_tariff)
    "#{user_tariff.name} (#{user_tariff.fuel_type}, #{user_tariff.start_date.to_s(:es_compact)} to #{user_tariff.end_date.to_s(:es_compact)})"
  end

  def user_tariff_charge_for_type(user_tariff_charges, charge_type)
    user_tariff_charges.find { |c| c.is_type?(charge_type) } || UserTariffCharge.new(charge_type: charge_type)
  end

  def user_tariff_charge_type_units_for(charge_type)
    settings(charge_type).fetch(:units, []).map { |k| [UserTariffCharge::CHARGE_TYPE_UNITS[k], k] }
  end

  def user_tariff_charge_type_units_humanized(charge_type_units)
    UserTariffCharge::CHARGE_TYPE_UNITS[charge_type_units.to_sym]
  end

  def user_tariff_charge_type_description(charge_type)
    settings(charge_type).fetch(:name, charge_type.to_s.humanize)
  end

  def user_tariff_charge_type_value_label(charge_type, default = 'Value in £')
    settings(charge_type).fetch(:label, default)
  end

  def settings(charge_type)
    UserTariffCharge::CHARGE_TYPES[charge_type.to_sym] || {}
  end
end
