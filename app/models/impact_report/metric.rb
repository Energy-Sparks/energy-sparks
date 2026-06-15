# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: impact_report_metrics
#
#  id                   :bigint(8)        not null, primary key
#  enough_data          :boolean          default(FALSE), not null
#  fuel_type            :integer
#  metric_category      :enum             not null
#  metric_type          :enum             not null
#  number_of_schools    :integer
#  unit                 :enum
#  value                :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  impact_report_run_id :bigint(8)        not null
#
# Indexes
#
#  index_impact_report_metrics_on_impact_report_run_id  (impact_report_run_id)
#  index_impact_report_metrics_unique                   (impact_report_run_id,metric_category,fuel_type,metric_type,unit) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (impact_report_run_id => impact_report_runs.id)
#
# rubocop:enable Layout/LineLength

module ImpactReport
  class Metric < ApplicationRecord
    self.table_name = 'impact_report_metrics'

    include Enums::FuelType

    belongs_to :run, foreign_key: :impact_report_run_id, class_name: 'ImpactReport::Run', inverse_of: :metrics
    validates :metric_type, uniqueness: { scope: %i[impact_report_run_id metric_category fuel_type unit] }

    scope :enough_data, -> { where(enough_data: true) }

    def self.enum_map(values)
      values.index_with(&:to_s)
    end

    METRIC_CATEGORIES = %i[
      overview
      energy_efficiency
      engagement
      potential_savings
    ].freeze
    enum :metric_category, enum_map(METRIC_CATEGORIES).freeze

    GENERATOR = SchoolGroups::ImpactReport::Generator
    private_constant :GENERATOR

    OVERVIEW_METRICS = GENERATOR::Overview::METRICS

    ENERGY_EFFICIENCY_GENERATORS = [
      GENERATOR::AnnualSaving,
      GENERATOR::Benchmark,
      GENERATOR::Targets,
      GENERATOR::Holiday,
      GENERATOR::OutOfHours
    ].freeze
    private_constant :ENERGY_EFFICIENCY_GENERATORS

    ENERGY_EFFICIENCY_METRICS = ENERGY_EFFICIENCY_GENERATORS.flat_map { |type| type::METRICS }.freeze

    ENGAGEMENT_METRICS = GENERATOR::Engagement::METRICS

    POTENTIAL_SAVINGS_METRICS = GENERATOR::PotentialSavings::METRICS

    METRIC_TYPES = (
      OVERVIEW_METRICS +
      ENGAGEMENT_METRICS +
      ENERGY_EFFICIENCY_METRICS +
      POTENTIAL_SAVINGS_METRICS
    ).uniq.freeze # uniq because targets is found in engagement and potential_savings

    enum :metric_type, enum_map(METRIC_TYPES).freeze, suffix: :metric

    def self.categories
      METRIC_CATEGORIES
    end

    def self.metrics(category)
      const_get("#{category.to_s.upcase}_METRICS")
    end

    def available?
      enough_data? && value.present?
    end

    def nonzero?
      available? && value.to_i.nonzero?
    end
  end
end
