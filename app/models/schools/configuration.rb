# == Schema Information
#
# Table name: configurations
#
#  analysis_charts          :json             not null
#  created_at               :datetime         not null
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

    enum gas_dashboard_chart_type: [:no_chart, :teachers_landing_page_gas_simple, :teachers_landing_page_gas]

    def analysis_charts_as_symbols
      configuration = {}
      analysis_charts.each do |page, config|
        config = config.deep_symbolize_keys
        config[:charts] = config[:charts].map(&:to_sym)
        configuration[page.to_sym] = config
      end
      configuration
    end
  end
end
