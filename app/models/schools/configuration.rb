# == Schema Information
#
# Table name: configurations
#
#  aggregate_meter_dates        :json
#  analysis_charts              :json             not null
#  created_at                   :datetime         not null
#  dashboard_charts             :string           default([]), not null, is an Array
#  estimated_consumption        :json
#  fuel_configuration           :json
#  id                           :bigint(8)        not null, primary key
#  pupil_analysis_charts        :json             not null
#  school_id                    :bigint(8)        not null
#  school_target_fuel_types     :string           default([]), not null, is an Array
#  suggest_estimates_fuel_types :string           default([]), not null, is an Array
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_configurations_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

module Schools
  class Configuration < ApplicationRecord
    belongs_to :school

    MANAGEMENT_DASHBOARD_CHARTS = {
      electricity: :management_dashboard_group_by_week_electricity,
      gas: :management_dashboard_group_by_week_gas,
      storage_heaters: :management_dashboard_group_by_week_storage_heater,
      solar_pv: :management_dashboard_group_by_month_solar_pv
    }.freeze

    delegate :has_electricity, :has_gas, :has_storage_heaters, :has_solar_pv, :fuel_types_for_analysis, :dual_fuel,
             to: :fuel_configuration

    def fuel_configuration
      FuelConfiguration.new(**super.symbolize_keys)
    end

    def enough_data_to_set_target?
      school_target_fuel_types.any?
    end

    def enough_data_to_set_target_for_fuel_type?(fuel_type)
      case fuel_type.to_s
      when 'storage_heater', 'storage_heaters'
        school_target_fuel_types.include?('storage_heater')
      else
        school_target_fuel_types.include?(fuel_type.to_s)
      end
    end

    def suggest_annual_estimate_for_fuel_type?(fuel_type)
      case fuel_type.to_s
      when 'storage_heater', 'storage_heaters'
        suggest_estimates_fuel_types.include?('storage_heater')
      else
        suggest_estimates_fuel_types.include?(fuel_type.to_s)
      end
    end

    def estimated_consumption_for_fuel_type(fuel_type)
      estimated_consumption.symbolize_keys[fuel_type.to_sym]
    end

    def analysis_charts_as_symbols(charts_field = :analysis_charts)
      configuration = {}
      self[charts_field].each do |page, config|
        configuration[page.to_sym] = symbolize_charts_config(config)
      end
      configuration
    end

    def get_charts(charts_field, page, *sub_pages)
      page_config = analysis_charts_as_symbols(charts_field).fetch(page) { {} }
      base_chart_config = sub_pages.inject(page_config) do |config, page_name|
        config[:sub_pages].find { |sub_page| sub_page[:name] == page_name } || { sub_pages: [] }
      end
      base_chart_config.fetch(:charts) { [] }
    end

    def can_show_analysis_chart?(charts_field, page, *sub_pages, chart_name)
      get_charts(charts_field, page, *sub_pages).include?(chart_name)
    end

    def meter_start_date(fuel_type)
      dates = meter_dates(fuel_type)
      dates.present? ? dates[:start_date] : nil
    end

    def meter_end_date(fuel_type)
      dates = meter_dates(fuel_type)
      dates.present? ? dates[:end_date] : nil
    end

    def meter_dates(fuel_type)
      dates = aggregate_meter_dates.deep_symbolize_keys
      dates_for_fuel_types = dates[fuel_type.to_sym]
      if dates_for_fuel_types.present?
        dates_for_fuel_types.transform_values { |v| Date.parse(v) }
      else
        {}
      end
    end

    def fuel_type?(fuel_type)
      fuel_configuration.public_send("has_#{fuel_type}")
    end

    private

    def symbolize_charts_config(charts_config)
      config = charts_config.deep_symbolize_keys
      if config.key?(:sub_pages)
        config[:sub_pages] = config[:sub_pages].map { |sub_page| symbolize_charts_config(sub_page) }
      else
        config[:charts] = config[:charts].map(&:to_sym)
      end
      config
    end
  end
end
