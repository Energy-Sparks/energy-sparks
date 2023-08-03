module EnergyTariffsHelper
  def energy_tariff_price_title(energy_tariff_price)
    if energy_tariff_price.description.present?
      "#{energy_tariff_price&.description} (#{energy_tariff_price&.start_time&.to_s(:time)} to #{energy_tariff_price&.end_time&.to_s(:time)})"
    else
      "Rate from #{energy_tariff_price&.start_time&.to_s(:time)} to #{energy_tariff_price&.end_time&.to_s(:time)}"
    end
  end

  def energy_tariff_prices_text(energy_tariff)
    if energy_tariff.energy_tariff_prices.map(&:description).include?(EnergyTariffPrice::NIGHT_RATE_DESCRIPTION)
      I18n.t('schools.tariffs_helper.prices_text')
    end
  end

  def energy_tariff_charge_for_type(energy_tariff_charges, charge_type)
    energy_tariff_charges.find { |c| c.is_type?([charge_type]) } || EnergyTariffCharge.new(charge_type: charge_type)
  end

  def energy_tariff_charge_type_description(charge_type)
    settings(charge_type).fetch(:name, charge_type.to_s.humanize)
  end

  def energy_tariff_charge_type_tip(charge_type)
    settings(charge_type).fetch(:tip, '')
  end

  def energy_tariff_charge_type_value_label(charge_type, default = 'Value in £')
    settings(charge_type).fetch(:label, default)
  end

  def energy_tariff_title(energy_tariff, with_mpxn = false)
    start_date = energy_tariff&.start_date&.to_s(:es_compact)
    end_date = energy_tariff&.end_date&.to_s(:es_compact)

    title = ''

    if start_date && end_date
      title += I18n.t(
        'schools.tariffs_helper.user_tariff_title',
        start_date: start_date,
        end_date: end_date
      )
      title += ' : '
    elsif start_date || end_date
      title = start_date.to_s + end_date.to_s + ' : '
    end

    title += "#{energy_tariff&.name} " if energy_tariff&.name&.present?

    if energy_tariff.meters.any? && with_mpxn
      if energy_tariff.gas?
        title += I18n.t('schools.tariffs_helper.for_mprn', user_tariff_meters_list: energy_tariff.meters.map(&:mpan_mprn).to_sentence)
      else
        title += I18n.t('schools.tariffs_helper.for_mpan', user_tariff_meters_list: energy_tariff.meters.map(&:mpan_mprn).to_sentence)
      end
    end

    title
  end

  def energy_tariff_charge_type_units_for(charge_type)
    settings(charge_type).fetch(:units, []).map { |k| [EnergyTariffCharge.charge_type_units[k], k] }
  end

  def energy_tariff_charge_value(energy_tariff_charge)
    if energy_tariff_charge.units
      I18n.t(
        'schools.tariffs_helper.charge_value',
        value: number_to_currency(energy_tariff_charge.value, unit: '£'),
        units: energy_tariff_charge_type_units_humanized(energy_tariff_charge.units)
      )
    else
      energy_tariff_charge.value.to_s
    end
  end

  def energy_tariff_charge_type_units_humanized(charge_type_units)
    EnergyTariffCharge.charge_type_units[charge_type_units.to_sym]
  end
end
