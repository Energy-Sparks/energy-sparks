module TariffsHelper
  def user_tariff_title(user_tariff, with_mpxn = false)
    start_date = user_tariff.start_date.to_s(:es_compact)
    end_date = user_tariff.end_date.to_s(:es_compact)

    title = I18n.t(
      'schools.tariffs_helper.user_tariff_title',
      start_date: start_date,
      end_date: end_date
    )
    title += " : #{user_tariff.name} " if user_tariff.name.present?

    if user_tariff.meters.any? && with_mpxn
      if user_tariff.gas?
        title += I18n.t('schools.tariffs_helper.for_mprn', user_tariff_meters_list: user_tariff.meters.map(&:mpan_mprn).to_sentence)
      else
        title += I18n.t('schools.tariffs_helper.for_mpan', user_tariff_meters_list: user_tariff.meters.map(&:mpan_mprn).to_sentence)
      end
    end

    title
  end

  def user_tariff_price_title(user_tariff_price)
    if user_tariff_price.description.present?
      "#{user_tariff_price.description} (#{user_tariff_price.start_time.to_s(:time)} to #{user_tariff_price.end_time.to_s(:time)})"
    else
      "Rate from #{user_tariff_price.start_time.to_s(:time)} to #{user_tariff_price.end_time.to_s(:time)}"
    end
  end

  def user_tariff_prices_text(user_tariff)
    if user_tariff.user_tariff_prices.map(&:description).include?(UserTariffPrice::NIGHT_RATE_DESCRIPTION)
      I18n.t('schools.tariffs_helper.prices_text')
    end
  end

  def user_tariff_charge_for_type(user_tariff_charges, charge_type)
    user_tariff_charges.find { |c| c.is_type?([charge_type]) } || UserTariffCharge.new(charge_type: charge_type)
  end

  def user_tariff_charge_type_units_for(charge_type)
    settings(charge_type).fetch(:units, []).map { |k| [UserTariffCharge.charge_type_units[k], k] }
  end

  def user_tariff_charge_type_units_humanized(charge_type_units)
    UserTariffCharge.charge_type_units[charge_type_units.to_sym]
  end

  def user_tariff_charge_type_description(charge_type)
    settings(charge_type).fetch(:name, charge_type.to_s.humanize)
  end

  def user_tariff_charge_value(user_tariff_charge)
    if user_tariff_charge.units
      I18n.t(
        'schools.tariffs_helper.charge_value',
        value: number_to_currency(user_tariff_charge.value, unit: '£'),
        units: user_tariff_charge_type_units_humanized(user_tariff_charge.units)
      )
    else
      user_tariff_charge.value.to_s
    end
  end

  def user_tariff_charge_type_value_label(charge_type, default = 'Value in £')
    settings(charge_type).fetch(:label, default)
  end

  def settings(charge_type)
    UserTariffCharge.charge_types[charge_type.to_sym] || {}
  end
end
