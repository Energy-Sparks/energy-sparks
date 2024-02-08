# == Schema Information
#
# Table name: comparison_metrics
#
#  alert_type_id             :bigint(8)        not null
#  asof_date                 :date
#  created_at                :datetime         not null
#  custom_current_period_id  :bigint(8)
#  custom_previous_period_id :bigint(8)
#  enough_data               :boolean          not null
#  id                        :bigint(8)        not null, primary key
#  metric_type_id            :bigint(8)        not null
#  recent_data               :boolean          not null
#  reporting_period          :integer
#  school_id                 :bigint(8)        not null
#  updated_at                :datetime         not null
#  value                     :string
#  whole_period              :boolean          not null
#
# Indexes
#
#  index_comparison_metrics_on_alert_type_id              (alert_type_id)
#  index_comparison_metrics_on_custom_current_period_id   (custom_current_period_id)
#  index_comparison_metrics_on_custom_previous_period_id  (custom_previous_period_id)
#  index_comparison_metrics_on_metric_type_id             (metric_type_id)
#  index_comparison_metrics_on_school_id                  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (custom_current_period_id => comparison_periods.id) ON DELETE => cascade
#  fk_rails_...  (custom_previous_period_id => comparison_periods.id) ON DELETE => cascade
#  fk_rails_...  (metric_type_id => comparison_metrics.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Comparison::Metric < ApplicationRecord
  self.table_name = 'comparison_metrics'

  # Add reporting periods as required?
  # [:last_12_months, :financial_year, :academic_year]
  enum reporting_period: { custom: 0 }

  belongs_to :school
  belongs_to :metric_type, class_name: 'Comparison::MetricType'
  belongs_to :alert_type
  belongs_to :custom_current_period, class_name: 'Comparison::Period', optional: true
  belongs_to :custom_previous_period, class_name: 'Comparison::Period', optional: true

  validates :value, presence: true
end
