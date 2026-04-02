# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_metrics
#
#  created_at           :datetime         not null
#  enough_data          :boolean          default(FALSE), not null
#  fuel_type            :integer
#  id                   :bigint(8)        not null, primary key
#  impact_report_run_id :bigint(8)        not null
#  metric_category      :integer          not null
#  metric_type          :integer          not null
#  number_of_schools    :integer
#  updated_at           :datetime         not null
#  value                :jsonb
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

    enum :metric_category, { overview: 0, energy_efficiency: 1, engagement: 2, potential_savings: 3 }, prefix: :category
    enum :metric_type, {  visible_schools: 0, # Not sure if this should be the name of a key instead
                          data_visible_schools: 1,
                          users: 2,
                          users_logged_in_recently: 3,
                          pupils: 4,
                          enrolled_schools: 5,
                          enrolling_schools: 6,
                          total_saving: 7,
                          reduced_emissions: 8,
                          activities: 9,
                          actions: 10,
                          points: 11,
                          featured_school: 12,
                          featured_school_activities: 13,
                          featured_school_actions: 14,
                          programmes: 15,
                          targets: 16 }, prefix: :type
  end
end
