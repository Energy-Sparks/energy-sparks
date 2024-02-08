# == Schema Information
#
# Table name: comparison_metrics
#
#  alert_type_id             :bigint(8)        not null
#  asof_date                 :date
#  comparison_metric_type_id :bigint(8)        not null
#  created_at                :datetime         not null
#  current_period_id         :bigint(8)        not null
#  enough_data               :boolean          not null
#  id                        :bigint(8)        not null, primary key
#  previous_period_id        :bigint(8)
#  recent_data               :boolean          not null
#  school_id                 :bigint(8)        not null
#  updated_at                :datetime         not null
#  value                     :string
#  whole_period              :boolean          not null
#
# Indexes
#
#  index_comparison_metrics_on_alert_type_id              (alert_type_id)
#  index_comparison_metrics_on_comparison_metric_type_id  (comparison_metric_type_id)
#  index_comparison_metrics_on_current_period_id          (current_period_id)
#  index_comparison_metrics_on_previous_period_id         (previous_period_id)
#  index_comparison_metrics_on_school_id                  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (comparison_metric_type_id => comparison_metric_types.id) ON DELETE => cascade
#  fk_rails_...  (current_period_id => comparison_periods.id) ON DELETE => cascade
#  fk_rails_...  (previous_period_id => comparison_periods.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Comparison::Metric < ApplicationRecord
  self.table_name = 'comparison_metrics'

  belongs_to :school, inverse_of: :metrics
  belongs_to :metric_type, class_name: 'Comparison::MetricType'
  belongs_to :alert_type

  belongs_to :current_period, class_name: 'Comparison::Period'
  belongs_to :previous_period, class_name: 'Comparison::Period'
end
