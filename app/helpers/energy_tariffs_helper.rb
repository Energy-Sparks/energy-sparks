module EnergyTariffsHelper
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
end
