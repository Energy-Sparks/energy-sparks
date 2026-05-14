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
    has_many :metrics, class_name: 'ImpactReport::Metric', inverse_of: :run, dependent: :destroy

    scope :latest, -> { includes(:metrics).order(run_date: :desc).first }

    LOOKUP_CATEGORIES = (ImpactReport::Metric.categories - %i[potential_savings energy_efficiency]).freeze

    def self.lookup_categories
      LOOKUP_CATEGORIES
    end

    # e.g. overview(:active_users)
    def overview(metric_type)
      by_category(:overview)[metric_type.to_s]
    end

    # e.g. engagement(:points)
    def engagement(metric_type)
      by_category(:engagement)[metric_type.to_s]
    end

    def potential_savings
      %w[electricity gas solar_pv].filter_map { |fuel| sorted_potential_savings(fuel) }
                                  .then do |groups|
                                    groups.map(&:size).max.to_i.times.flat_map do |i|
                                      groups.filter_map { |g| g[i] }
                                    end
                                  end
    end

    private

    def by_category(category)
      metrics_index[category.to_s]
    end

    def metrics_index
      @metrics_index ||= metrics.each_with_object({}) do |metric, hash|
        next if metric.units && metric.units != 'gbp' # ignore non-gbp for now

        store_metric(hash, metric)
      end
    end

    def store_metric(hash, metric)
      category = metric.metric_category

      hash[category] ||= {}
      if category == 'potential_savings'
        (hash[category][metric.fuel_type] ||= []) << metric
      else
        hash[category][metric.metric_type] = metric
      end
    end

    def sorted_potential_savings(fuel)
      by_category(:potential_savings)
        .to_h
        .fetch(fuel) { [] }
        .select(&:nonzero?)
        .sort_by { |m| -m.value }
        .presence
    end
  end
end
