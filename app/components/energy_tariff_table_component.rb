# Displays a tabular view of a set of tariffs owned by the same tariff holder
# and of the same type.
class EnergyTariffTableComponent < ViewComponent::Base
  include EnergyTariffsHelper

  delegate :can?, :cannot?, to: :helpers

  def initialize(id: 'tariff-table', tariff_holder:, tariffs:, show_actions: true)
    @id = id
    @tariff_holder = tariff_holder
    @tariffs = tariffs
    @show_actions = show_actions
  end

  def show_meters?
    @tariff_holder.school?
  end

  def flat_rate_label(energy_tariff)
    energy_tariff.flat_rate? ? t('schools.user_tariffs.tariff_partial.simple_tariff') : t('schools.user_tariffs.tariff_partial.day_night_tariff')
  end

  def start_date(energy_tariff)
    energy_tariff.start_date ? energy_tariff.start_date&.to_s(:es_compact) : t('schools.user_tariffs.summary_table.no_start_date')
  end

  def start_date_sortable(energy_tariff)
    energy_tariff.start_date&.iso8601
  end

  def end_date_sortable(energy_tariff)
    energy_tariff.end_date&.iso8601
  end

  def table_sorted
    @tariffs.length > 1 ? 'table-sorted' : ''
  end

  def end_date(energy_tariff)
    energy_tariff.end_date ? energy_tariff.end_date&.to_s(:es_compact) : t('schools.user_tariffs.summary_table.no_end_date')
  end

  def show_actions?
    @show_actions
  end
end
