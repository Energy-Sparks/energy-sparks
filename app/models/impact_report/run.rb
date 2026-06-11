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

    scope :latest_first, -> { order(run_date: :desc, created_at: :desc) }
    scope :latest, -> { includes(:metrics).latest_first.first }

    SUPPORTED_ENERGY_EFFICIENCY_METRICS = [
      %w[annual_saving gbp],
      %w[holiday_previous_year gbp],
      %w[holiday_previous gbp],
      %w[annual_saving co2],
      ['targets', nil],
      ['out_of_hours', nil],
      ['long_term', nil],
      ['baseload', nil],
      ['heating_control', nil]
    ].freeze
    private_constant :SUPPORTED_ENERGY_EFFICIENCY_METRICS

    def end_date
      run_date - 1.day
    end

    def start_date
      end_date - 364.days
    end

    def comparison_end_date
      start_date - 1.day
    end

    def comparison_start_date
      comparison_end_date - 364.days
    end

    def enough_data?
      overview(:visible_schools).then do |metric|
        metric.present? && metric.available? && metric&.value.to_i >= 2
      end
    end

    # e.g. overview(:active_users)
    def overview(metric_type)
      by_category(:overview).dig(metric_type.to_s, nil)
    end

    # e.g. engagement(:points)
    def engagement(metric_type)
      by_category(:engagement).dig(metric_type.to_s, nil)
    end

    def potential_savings
      fuel_order = %w[electricity gas solar_pv]
      fuel_order.filter_map { |fuel| sorted_potential_savings(fuel) }
                .then do |groups|
                  groups.map(&:size).max.to_i.times.flat_map do |i|
                    groups.filter_map { |g| g[i] }
                  end
                end
    end

    def energy_efficiency(gbp_threshold: self.class.gbp_threshold)
      fuel_order = %w[gas electricity]
      unit_order = %w[gbp co2 kwh]
      metrics.filter { |metric| displayable_energy_efficiency_metric?(metric, gbp_threshold) }.sort_by do |metric|
        [SUPPORTED_ENERGY_EFFICIENCY_METRICS.index([metric.metric_type, metric.unit]),
         unit_order.index(metric.unit),
         fuel_order.index(metric.fuel_type)]
      end
    end

    class << self
      def gbp_threshold
        @gbp_threshold ||= Commercial::Product.default_product.try(:large_school_price).to_i
      end
    end

    private

    def by_category(category)
      metrics_index[category.to_s] || {}
    end

    def metrics_index
      @metrics_index ||= metrics.each_with_object({}) do |metric, hash|
        hash[metric.metric_category] ||= {}

        if metric.metric_category == 'potential_savings'
          store_potential_savings_metric(hash, metric)
        else
          store_metric(hash, metric)
        end
      end
    end

    def store_potential_savings_metric(hash, metric)
      return if metric.unit.present? && metric.unit != :gbp

      (hash[metric.metric_category][metric.fuel_type] ||= []) << metric
    end

    def store_metric(hash, metric)
      (hash[metric.metric_category][metric.metric_type] ||= {})[metric.fuel_type] = metric
    end

    def sorted_potential_savings(fuel)
      by_category(:potential_savings)
        .to_h
        .fetch(fuel) { [] }
        .select(&:nonzero?)
        .sort_by { |m| -m.value }
        .presence
    end

    def displayable_energy_efficiency_metric?(metric, gbp_threshold)
      metric.metric_category == 'energy_efficiency' &&
        SUPPORTED_ENERGY_EFFICIENCY_METRICS.include?([metric.metric_type, metric.unit]) &&
        metric.nonzero? &&
        (metric.unit != 'gbp' || metric.value > gbp_threshold)
    end
  end
end
