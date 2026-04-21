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
#  value                :jsonb
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

    METRIC_CATEGORIES = {
      overview: 'overview',
      energy_efficiency: 'energy_efficiency',
      engagement: 'engagement',
      potential_savings: 'potential_savings'
    }.freeze

    enum :metric_category, METRIC_CATEGORIES, prefix: :category

    OVERVIEW_METRICS = {
      schools: 'schools',
      users: 'users',
      pupils: 'pupils',
      enrolled_schools: 'enrolled_schools'
    }.freeze

    ENERGY_EFFICIENCY_METRICS = {
      total_saving: 'total_saving'
      # more energy efficiency metrics can be added here as needed
    }.freeze

    ENGAGEMENT_METRICS = {
      activities: 'activities',
      actions: 'actions',
      points: 'points',
      targets: 'targets'
    }.freeze

    POTENTIAL_SAVINGS_METRICS = {
      # Placeholder for potential savings metrics
    }.freeze

    METRIC_TYPES = { **OVERVIEW_METRICS, **ENGAGEMENT_METRICS, **ENERGY_EFFICIENCY_METRICS,
**POTENTIAL_SAVINGS_METRICS }.freeze

    enum :metric_type, METRIC_TYPES, prefix: :type
  end
end
