module EnergyTariffsHelper
  def cost_analysis_class_for(meter_type)
    case meter_type
    when 'electricity' then 'AdviceElectricityCosts'
    when 'gas' then 'AdviceGasCosts'
    end
  end

  def energy_tariffs_path(energy_tariff, path = [], options = {})
    if options[:energy_tariff_index] == true
      polymorphic_path(tariff_holder_route(energy_tariff.tariff_holder) + [:energy_tariffs] + path, options)
    else
      polymorphic_path(tariff_holder_route(energy_tariff.tariff_holder) + [energy_tariff] + path, options)
    end
  end

  def new_energy_tariff_path(tariff_holder, options = {})
    if tariff_holder.school?
      choose_meters_school_energy_tariffs_path(tariff_holder, options)
    else
      polymorphic_path(tariff_holder_route(tariff_holder) + [:energy_tariff], options.merge!({ action: :new }))
    end
  end

  def energy_tariff_prices_path(energy_tariff, options = {})
    if energy_tariff.flat_rate?
      energy_tariffs_path(energy_tariff, [:energy_tariff_flat_prices], options)
    else
      energy_tariffs_path(energy_tariff, [:energy_tariff_differential_prices], options)
    end
  end

  def tariff_holder_route(tariff_holder)
    if tariff_holder.site_settings?
      [:admin, :settings]
    else
      [tariff_holder]
    end
  end

  def list_of_tariff_types(show_all: true)
    show_all ? EnergyTariff.meter_types.keys : Meter::MAIN_METER_TYPES
  end

  def sorted_tariffs(tariff_holder, meter_type, source = :manually_entered)
    tariff_holder.energy_tariffs.where(meter_type: meter_type, source: source).by_start_and_end.by_name
  end

  def site_settings_page?
    request.path.start_with?('/admin/settings')
  end

  def convert_value_to_long_currency(value, currency: '£')
    return '' unless value.is_a? Numeric
    value_as_string = value.to_s
    split_value = value_as_string.split('.')

    value_as_formatted_currency = if split_value.size == 1
                                    split_value.first + '.00'
                                  elsif split_value.last.length < 2
                                    split_value.first + '.' + split_value.last + '0'
                                  else
                                    value_as_string
                                  end

    currency + value_as_formatted_currency
  end

  def energy_tariff_price_title(energy_tariff_price)
    I18n.t(
      'schools.tariffs_helper.rate_from',
      start_time: energy_tariff_price&.start_time&.to_s(:time),
      end_time: energy_tariff_price&.end_time&.to_s(:time)
    )
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

  def energy_tariff_charge_type_units_for(charge_type)
    settings(charge_type).fetch(:units, []).map { |k| [EnergyTariffCharge.charge_type_units[k], k] }
  end

  def energy_tariff_charge_value(energy_tariff_charge)
    if energy_tariff_charge.units
      I18n.t(
        'schools.tariffs_helper.charge_value',
        value: convert_value_to_long_currency(energy_tariff_charge.value),
        units: energy_tariff_charge_type_units_humanized(energy_tariff_charge.units)
      )
    else
      energy_tariff_charge.value.to_s
    end
  end

  def energy_tariff_charge_type_units_humanized(charge_type_units)
    EnergyTariffCharge.charge_type_units[charge_type_units.to_sym]
  end

  def settings(charge_type)
    EnergyTariffCharge.charge_types[charge_type.to_sym] || {}
  end

  def any_smart_meters?(school)
    school.meters.dcc.any?
  end
end
