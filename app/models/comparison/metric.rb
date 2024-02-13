# == Schema Information
#
# Table name: comparison_metrics
#
#  alert_type_id                             :bigint(8)        not null
#  asof_date                                 :date
#  benchmark_result_school_generation_run_id :bigint(8)
#  created_at                                :datetime         not null
#  custom_period_id                          :bigint(8)
#  enough_data                               :boolean          default(FALSE)
#  id                                        :bigint(8)        not null, primary key
#  metric_type_id                            :bigint(8)        not null
#  recent_data                               :boolean          default(FALSE)
#  reporting_period                          :integer
#  school_id                                 :bigint(8)        not null
#  updated_at                                :datetime         not null
#  value                                     :string
#  whole_period                              :boolean          default(FALSE)
#
# Indexes
#
#  idx_benchmark_school_run_metrics              (benchmark_result_school_generation_run_id)
#  index_comparison_metrics_on_alert_type_id     (alert_type_id)
#  index_comparison_metrics_on_custom_period_id  (custom_period_id)
#  index_comparison_metrics_on_metric_type_id    (metric_type_id)
#  index_comparison_metrics_on_school_id         (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (custom_period_id => comparison_periods.id) ON DELETE => cascade
#  fk_rails_...  (metric_type_id => comparison_metrics.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Comparison::Metric < ApplicationRecord
  self.table_name = 'comparison_metrics'

  include EnumReportingPeriod

  belongs_to :school
  belongs_to :alert_type
  belongs_to :metric_type, class_name: 'Comparison::MetricType'
  belongs_to :custom_period, class_name: 'Comparison::Period', optional: true
  belongs_to :benchmark_result_school_generation_run

  validates :school, :alert_type, :metric_type, presence: true
  validates :custom_period, presence: true, if: :custom?
end
