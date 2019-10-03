# == Schema Information
#
# Table name: configurations
#
#  analysis_charts                     :json             not null
#  created_at                          :datetime         not null
#  fuel_configuration                  :json
#  gas_dashboard_chart_type            :integer          default("no_chart"), not null
#  id                                  :bigint(8)        not null, primary key
#  pupil_analysis_charts               :json             not null
#  school_id                           :bigint(8)        not null
#  storage_heater_dashboard_chart_type :integer          default(0), not null
#  updated_at                          :datetime         not null
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

    NO_GAS_CHART = :no_gas_chart
    NO_STORAGE_HEATER_CHART = :no_storaage_heater_chart
    TEACHERS_GAS_SIMPLE = :teachers_landing_page_gas_simple
    TEACHERS_GAS = :teachers_landing_page_gas
    TEACHERS_ELECTRICITY = :teachers_landing_page_electricity
    TEACHERS_STORAGE_HEATERS_SIMPLE = :teachers_landing_page_storage_heaters_simple
    TEACHERS_STORAGE_HEATERS = :teachers_landing_page_storage_heaters

    TEACHERS_DASHBOARD_CHARTS = [TEACHERS_GAS_SIMPLE, TEACHERS_GAS, TEACHERS_ELECTRICITY, TEACHERS_STORAGE_HEATERS, TEACHERS_STORAGE_HEATERS_SIMPLE].freeze

    enum gas_dashboard_chart_type: [NO_GAS_CHART, TEACHERS_GAS_SIMPLE, TEACHERS_GAS]
    enum storage_heater_dashboard_chart_type: [NO_STORAGE_HEATER_CHART, TEACHERS_STORAGE_HEATERS_SIMPLE, TEACHERS_STORAGE_HEATERS]


    delegate :has_electricity, :has_gas, :has_storage_heaters, :has_solar_pv, :fuel_types_for_analysis, :dual_fuel,
      to: :fuel_configuration

    def fuel_configuration
      FuelConfiguration.new(**super.symbolize_keys)
    end

    def analysis_charts_as_symbols(charts_field = :analysis_charts)
      configuration = {}
      self[charts_field].each do |page, config|
        configuration[page.to_sym] = symbolize_charts_config(config)
      end
      configuration
    end

    def get_charts(charts_field, page, *sub_pages)
      page_config = analysis_charts_as_symbols(charts_field).fetch(page) {{}}
      base_chart_config = sub_pages.inject(page_config) do |config, page_name|
        config[:sub_pages].find {|sub_page| sub_page[:name] == page_name} || { sub_pages: [] }
      end
      base_chart_config.fetch(:charts) {[]}
    end

    def can_show_analysis_chart?(charts_field, page, *sub_pages, chart_name)
      get_charts(charts_field, page, *sub_pages).include?(chart_name)
    end

    private

    def symbolize_charts_config(charts_config)
      config = charts_config.deep_symbolize_keys
      if config.key?(:sub_pages)
        config[:sub_pages] = config[:sub_pages].map {|sub_page| symbolize_charts_config(sub_page) }
      else
        config[:charts] = config[:charts].map(&:to_sym)
      end
      config
    end
  end
end
