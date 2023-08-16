# Displays a tabular view of a set of tariffs owned by the same tariff holder
# and of the same type.
class EnergyTariffTableComponent < ViewComponent::Base
  include EnergyTariffsHelper

  delegate :can?, :cannot?, to: :helpers

  def initialize(tariff_holder:, meter_type:, tariffs:, show_actions: true)
    @tariff_holder = tariff_holder
    @meter_type = meter_type
    @tariffs = tariffs
    @show_actions = show_actions
  end

  def table_id
    if @as_default
      "#{@meter_type}-default-tariffs-table"
    else
      "#{@meter_type}-tariffs-table"
    end
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

  def end_date(energy_tariff)
    energy_tariff.end_date ? energy_tariff.end_date&.to_s(:es_compact) : t('schools.user_tariffs.summary_table.no_end_date')
  end

  def show_actions?
    @show_actions
  end
end
