# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_runs
#
#  id              :bigint(8)        not null, primary key
#  run_date        :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_group_id :bigint(8)        not null
#
# Indexes
#
#  index_impact_report_runs_on_school_group_id  (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id)
#

module ImpactReport
  class Run < ApplicationRecord
    self.table_name = 'impact_report_runs'

    belongs_to :school_group
    has_many :metrics, class_name: 'ImpactReport::Metric', inverse_of: :impact_report_run, dependent: :destroy

    scope :latest, -> { includes(:metrics).order(run_date: :desc).first }

    # e.g. overview(:active_users)
    %i[overview engagement].each do |category|
      define_method(category) do |type, fuel_type = nil|
        metric(category, type, fuel_type)
      end
    end

    # Putting the logic here for ordering as might want this for the admin interface
    def potential_savings
      # This is the order we would like to pick them
      # only using gpb metrics for now
      %w[electricity solar_pv gas storage_heater].map do |fuel_type|
        by_category(:potential_savings).fetch(fuel_type, {}).values
                                       .select { |metric| metric.units == 'gbp' && metric.nonzero? }
                                       .sort_by { |metric| -metric.value }
      end.reduce(&:zip).flatten.compact
    end

    def metric(category, metric_type, fuel_type = nil)
      metrics_index.dig(category.to_s, fuel_type&.to_s, metric_type.to_s)
    end

    def by_category(category)
      metrics_index[category.to_s]
    end

    def metrics_index
      @metrics_index ||= metrics.each_with_object({}) do |metric, hash|
        category = metric.metric_category
        fuel_type = metric.fuel_type

        hash[category] ||= {}
        hash[category][fuel_type] ||= {}
        hash[category][fuel_type][metric.metric_type] ||= metric
      end
    end
  end
end
