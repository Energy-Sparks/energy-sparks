# frozen_string_literal: true

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
#  value                :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  impact_report_run_id :bigint(8)        not null
#
# Indexes
#
#  index_impact_report_metrics_on_impact_report_run_id  (impact_report_run_id)
#
# Foreign Keys
#
#  fk_rails_...  (impact_report_run_id => impact_report_runs.id)
#
module ImpactReport
  class Metric < ApplicationRecord
    self.table_name = 'impact_report_metrics'

    include Enums::FuelType

    belongs_to :run, foreign_key: :impact_report_run_id, class_name: 'ImpactReport::Run', inverse_of: :metrics

    def self.enum_map(values)
      values.index_with(&:to_s)
    end

    GENERATOR = SchoolGroups::ImpactReport::Generator

    METRIC_CATEGORIES = %i[
      overview
      energy_efficiency
      engagement
      potential_savings
      footnote
    ].freeze

    enum :metric_category, enum_map(METRIC_CATEGORIES).freeze

    OVERVIEW_METRICS = %i[
      visible_schools
      data_visible_schools
      users
      active_users
      pupils
      enrolled_schools
      enrolling_schools
    ].freeze

    ENERGY_EFFICIENCY_GENERATORS = [
      GENERATOR::AnnualSaving,
      GENERATOR::Benchmark,
      GENERATOR::Targets
    ].freeze

    ENERGY_EFFICIENCY_METRICS = (
      %i[total_savings] + # not sure we need this now. Remove from DB too?
      ENERGY_EFFICIENCY_GENERATORS.flat_map { |type| type::METRICS }
    ).freeze

    ENGAGEMENT_METRICS = %i[
      activities
      actions
      points
      targets
    ].freeze

    POTENTIAL_SAVINGS_METRICS = GENERATOR::PotentialSavings::METRICS

    FOOTNOTE_METRICS = %i[].freeze

    METRIC_TYPES = (
      OVERVIEW_METRICS +
      ENGAGEMENT_METRICS +
      ENERGY_EFFICIENCY_METRICS +
      POTENTIAL_SAVINGS_METRICS +
      FOOTNOTE_METRICS
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

    def key
      key_and_unit.first&.to_sym
    end

    def unit
      key_and_unit[1]&.to_sym
    end

    def energy_efficiency_type
      return unless energy_efficiency?

      ENERGY_EFFICIENCY_GENERATORS.find { |type| type::METRICS.include?(metric_type.to_sym) }
                                  &.name.to_s.demodulize.underscore.to_sym
    end

    private

    ## I would like to see the unit in it's own field on metric as this is clunky
    def key_and_unit
      @key_and_unit ||= metric_type.match(
        /(.+?)(?:_(#{GENERATOR::PotentialSavings::TYPES.join('|')}))?$/
      ).captures
    end
  end
end
