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
#  value                :integer          not null
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

    belongs_to :impact_report_run, class_name: 'ImpactReport::Run', inverse_of: :metrics

    def self.enum_map(values)
      values.index_with(&:to_s)
    end

    METRIC_CATEGORIES = %i[
      overview
      energy_efficiency
      engagement
      potential_savings
      footnotes
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

    ENERGY_EFFICIENCY_METRICS = %i[
      total_savings
    ].freeze
    # More to come here

    ENGAGEMENT_METRICS = %i[
      activities
      actions
      points
      targets
    ].freeze

    POTENTIAL_SAVINGS_METRICS = %i[].freeze
    # e.g.:
    # reducing_out_of_hours_usage

    FOOTNOTE_METRICS = %i[].freeze

    METRIC_TYPES = (
      OVERVIEW_METRICS +
      ENGAGEMENT_METRICS +
      ENERGY_EFFICIENCY_METRICS +
      POTENTIAL_SAVINGS_METRICS +
      FOOTNOTE_METRICS).freeze

    enum :metric_type, enum_map(METRIC_TYPES).freeze, prefix: :type
  end
end
