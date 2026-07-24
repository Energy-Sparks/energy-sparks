# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_runs
#
#  id              :bigint(8)        not null, primary key
#  run_date        :date             not null
#  visible_schools :integer          default(0), not null
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

    INDEXED_CATEGORIES = %w[overview engagement].freeze
    private_constant :INDEXED_CATEGORIES

    SUPPORTED_ENERGY_EFFICIENCY_METRICS = {
      gbp: %w[annual_saving holiday_previous_year holiday_previous],
      count: %w[targets out_of_hours long_term baseload heating_control],
      co2: %w[annual_saving]
    }.freeze
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
      visible_schools >= 2
    end

    def overview(metric_type)
      metrics_index['overview']&.[](metric_type.to_s)
    end

    def engagement(metric_type)
      metrics_index['engagement']&.[](metric_type.to_s)
    end

    def energy_efficiency(gbp_threshold: self.class.gbp_threshold)
      unit_order = SUPPORTED_ENERGY_EFFICIENCY_METRICS.keys

      metrics
        .filter { |metric| displayable_energy_efficiency_metric?(metric, gbp_threshold) }
        .sort_by do |metric|
          [
            unit_order.index(metric.unit&.to_sym || :count),
            -metric.value.to_f
          ]
        end
    end

    def potential_savings
      fuel_order = %w[electricity gas solar_pv]
      grouped = grouped_potential_savings
      max_size = grouped.values.map(&:size).max || 0

      (0...max_size).flat_map do |i|
        fuel_order.filter_map do |fuel_type|
          grouped[fuel_type]&.[](i)
        end
      end
    end

    class << self
      def gbp_threshold_product
        Commercial::Product.default_product
      end

      def gbp_threshold_price
        :large_school_price
      end

      def gbp_threshold
        gbp_threshold_product.try(gbp_threshold_price).to_i
      end
    end

    private

    def metrics_index
      @metrics_index ||= metrics.each_with_object({}) do |metric, hash|
        if INDEXED_CATEGORIES.include?(metric.metric_category)
          hash[metric.metric_category] ||= {}
          hash[metric.metric_category][metric.metric_type] ||= metric
        end
      end
    end

    # Displayable potential savings metrics grouped by fuel type, highest value first
    def grouped_potential_savings
      @grouped_potential_savings ||=
        metrics
        .filter { |metric| displayable_potential_savings_metric?(metric) }
        .group_by(&:fuel_type)
        .transform_values do |metrics|
          metrics.sort_by do |metric|
            -metric.value.to_f
          end
        end
    end

    def displayable_energy_efficiency_metric?(metric, gbp_threshold)
      metric.metric_category == 'energy_efficiency' &&
        supported_energy_efficiency_metric?(metric) &&
        metric.nonzero? &&
        (metric.unit != 'gbp' || metric.value > gbp_threshold)
    end

    def supported_energy_efficiency_metric?(metric)
      unit = metric.unit&.to_sym || :count

      SUPPORTED_ENERGY_EFFICIENCY_METRICS
        .fetch(unit) { [] }
        .include?(metric.metric_type)
    end

    def displayable_potential_savings_metric?(metric)
      metric.metric_category == 'potential_savings' && metric.nonzero?
    end
  end
end
