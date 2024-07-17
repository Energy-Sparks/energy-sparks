# frozen_string_literal: true

module ArbitraryPeriodComparisonView
  extend ActiveSupport::Concern

  def any_tariff_changed?
    electricity_tariff_has_changed || gas_tariff_has_changed || storage_heater_tariff_has_changed
  end

  # For CSV export
  def fuel_type_names
    codes = []
    codes << I18n.t('common.electricity') if electricity_previous_period_kwh
    codes << I18n.t('common.gas') if gas_previous_period_kwh
    codes << I18n.t('common.storage_heaters') if storage_heater_previous_period_kwh
    codes.join(';')
  end

  included do
    scope :with_data_for_previous_period, lambda {
      where_any_present(
        %i[electricity_previous_period_kwh gas_previous_period_kwh storage_heater_previous_period_kwh]
      )
    }

    scope :by_total_percentage_change, lambda {
      by_percentage_change_across_fields(
        %i[electricity_previous_period_kwh gas_previous_period_kwh storage_heater_previous_period_kwh],
        %i[electricity_current_period_kwh gas_current_period_kwh storage_heater_current_period_kwh]
      )
    }
  end
end
