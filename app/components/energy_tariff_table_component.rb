# Displays a tabular view of a set of tariffs owned by the same tariff holder
# and of the same type.
class EnergyTariffTableComponent < ApplicationComponent
  include EnergyTariffsHelper

  delegate :can?, :cannot?, to: :helpers

  def initialize(id: 'tariff-table', tariff_holder:, tariffs:, show_actions: true, show_prices: true, **_kwargs)
    super
    @tariff_holder = tariff_holder
    @tariffs = tariffs
    @show_actions = show_actions
    @show_prices = show_prices
  end

  def show_prices?
    @show_prices
  end

  def show_meters?
    @tariff_holder.school?
  end

  def can_toggle_status?(energy_tariff)
    @tariff_holder.site_settings? || energy_tariff.dcc?
  end

  def can_delete?(energy_tariff)
    return false if energy_tariff.dcc?
    return false if @tariff_holder.site_settings? && energy_tariff.enabled?
    true
  end

  def show_actions?
    @show_actions
  end

  def start_time(price)
    price.start_time.to_fs(:time)
  end

  def end_time(price)
    price.end_time.to_fs(:time)
  end

  def flat_rate_label(energy_tariff)
    energy_tariff.flat_rate? ? t('schools.user_tariffs.tariff_partial.flat_rate_tariff') : t('schools.user_tariffs.tariff_partial.differential_tariff')
  end

  def start_date(energy_tariff)
    energy_tariff.start_date ? energy_tariff.start_date&.to_fs(:es_compact) : t('schools.user_tariffs.summary_table.no_start_date')
  end

  def start_date_sortable(energy_tariff)
    energy_tariff.start_date&.iso8601
  end

  def end_date(energy_tariff)
    energy_tariff.end_date ? energy_tariff.end_date&.to_fs(:es_compact) : t('schools.user_tariffs.summary_table.no_end_date')
  end

  def end_date_sortable(energy_tariff)
    energy_tariff.end_date&.iso8601
  end

  def table_sorted
    @tariffs.length > 1 ? 'table-sorted' : ''
  end

  def class_for_tariff(energy_tariff)
    return 'table-secondary' unless energy_tariff.enabled
    return 'table-danger' unless energy_tariff.usable?
  end
end
