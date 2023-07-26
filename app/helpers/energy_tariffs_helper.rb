module EnergyTariffsHelper
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
    start_date = energy_tariff.start_date.to_s(:es_compact)
    end_date = energy_tariff.end_date.to_s(:es_compact)

    title = I18n.t(
      'schools.tariffs_helper.user_tariff_title',
      start_date: start_date,
      end_date: end_date
    )
    title += " : #{energy_tariff.name} " if energy_tariff.name.present?

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
end
