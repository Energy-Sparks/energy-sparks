# == Schema Information
#
# Table name: configurations
#
#  analysis_charts          :json             not null
#  created_at               :datetime         not null
#  electricity              :boolean          default(FALSE), not null
#  gas                      :boolean          default(FALSE), not null
#  gas_dashboard_chart_type :integer          default("no_chart"), not null
#  id                       :bigint(8)        not null, primary key
#  school_id                :bigint(8)        not null
#  updated_at               :datetime         not null
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

    NO_CHART = :no_chart
    TEACHERS_GAS_SIMPLE = :teachers_landing_page_gas_simple
    TEACHERS_GAS = :teachers_landing_page_gas
    TEACHERS_ELECTRICITY = :teachers_landing_page_electricity

    TEACHERS_DASHBOARD_CHARTS = [TEACHERS_GAS_SIMPLE, TEACHERS_GAS, TEACHERS_ELECTRICITY].freeze

    enum gas_dashboard_chart_type: [NO_CHART, TEACHERS_GAS_SIMPLE, TEACHERS_GAS]

    def analysis_charts_as_symbols
      configuration = {}
      analysis_charts.each do |page, config|
        config = config.deep_symbolize_keys
        config[:charts] = config[:charts].map(&:to_sym)
        configuration[page.to_sym] = config
      end
      configuration
    end

    def can_show_analysis_chart?(page, chart_name)
      analysis_charts_as_symbols.fetch(page) {{}}.fetch(:charts) {[]}.include?(chart_name)
    end
  end
end
