# frozen_string_literal: true

# == Schema Information
#
# Table name: comparison_annual_energy_uses
#
#  alert_generation_run_id        :bigint(8)
#  electricity_last_year_co2      :float
#  electricity_last_year_gbp      :float
#  electricity_last_year_kwh      :float
#  electricity_tariff_has_changed :boolean
#  floor_area                     :float
#  gas_last_year_co2              :float
#  gas_last_year_gbp              :float
#  gas_last_year_kwh              :float
#  gas_tariff_has_changed         :boolean
#  id                             :bigint(8)
#  pupils                         :float
#  school_id                      :bigint(8)
#  school_type_name               :text
#  storage_heaters_last_year_co2  :float
#  storage_heaters_last_year_gbp  :float
#  storage_heaters_last_year_kwh  :float
#
# Indexes
#
#  index_comparison_annual_energy_uses_on_school_id  (school_id) UNIQUE
#
module Comparison
  class AnnualEnergyUse < Comparison::View
    self.table_name = 'comparison_annual_energy_uses'

    scope :with_data, lambda {
      where('electricity_last_year_kwh IS NOT NULL OR gas_last_year_kwh IS NOT NULL OR storage_heaters_last_year_kwh IS NOT NULL')
    }
    scope :sort_default, lambda {
      by_total(%i[electricity_last_year_kwh gas_last_year_kwh storage_heaters_last_year_kwh], 'DESC NULLS LAST')
    }

    def any_tariff_changed?
      electricity_tariff_has_changed || gas_tariff_has_changed
    end

    # For CSV export
    def fuel_type_names
      codes = []
      codes << I18n.t('common.electricity') if electricity_previous_period_kwh
      codes << I18n.t('common.gas') if gas_previous_period_kwh
      codes << I18n.t('common.storage_heaters') if storage_heater_previous_period_kwh
      codes << I18n.t('common.solar_pv') if solar_type.present?
      codes.join(';')
    end
  end
end
