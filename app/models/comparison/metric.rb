class Comparison::Metric < ApplicationRecord
  belongs_to :school, inverse_of: :comparison_metrics
  belongs_to :comparison_metric_type, inverse_of: :comparison_metrics
  belongs_to :alert_type, inverse_of: :comparison_metrics

  belongs_to :current_period, class_name: 'Comparison::Period'
  belongs_to :previous_period, class_name: 'Comparison::Period'
end
