#Handles display of page title and subtitle for forms
class EnergyTariffFormTitleComponent < ViewComponent::Base
  renders_one :page_title
  renders_one :notice

  def initialize(energy_tariff:, skip_fields: [])
    @energy_tariff = energy_tariff
    @skip_fields = skip_fields
  end

  def skip_field?(field)
    @skip_fields.include?(field)
  end

  def name
    @energy_tariff.name
  end

  def type_label
    @energy_tariff.flat_rate? ? t('schools.user_tariffs.tariff_partial.simple_tariff') : t('schools.user_tariffs.tariff_partial.day_night_tariff')
  end

  def dates
    start_date = @energy_tariff&.start_date&.to_s(:es_compact)
    end_date = @energy_tariff&.end_date&.to_s(:es_compact)

    if start_date && end_date
      I18n.t(
        'schools.tariffs_helper.user_tariff_title',
        start_date: start_date,
        end_date: end_date
      )
    elsif start_date || end_date
      start_date.to_s + end_date.to_s
    end
  end
end
