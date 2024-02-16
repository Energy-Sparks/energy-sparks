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
#  fk_rails_...  (metric_type_id => comparison_metric_types.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#


class Comparison::Metric < ApplicationRecord
  self.table_name = 'comparison_metrics'

  include EnumReportingPeriod

  attribute :value, :dynamic_type

  belongs_to :school
  belongs_to :alert_type
  belongs_to :metric_type, class_name: 'Comparison::MetricType'
  belongs_to :custom_period, class_name: 'Comparison::Period', optional: true
  belongs_to :benchmark_result_school_generation_run

  validates :school, :alert_type, :metric_type, presence: true
  validates :custom_period, presence: true, if: :custom?

  scope :with_metric_type, -> { includes(:metric_type) }
  scope :with_school, -> { includes(:school) }
  scope :with_school_and_metric_type, -> { with_school.with_metric_type }

  scope :with_run, -> { joins(:benchmark_result_school_generation_run) }

  scope :for_metric_type, ->(metric_type) { where(metric_type: metric_type) }
  scope :for_schools, ->(schools) { where(school: schools) }
  scope :has_value, -> { where.not(value: nil) }

  # Returns only those metrics associated with the latest benchmark run for each school
  scope :for_latest_benchmark_runs, -> { with_run.merge(BenchmarkResultSchoolGenerationRun.most_recent) }

  # Applies a custom sort order
  # First ranks the schools by a specific metric type (asc or desc) and then
  # uses that ranking to order the returned list of metrics.
  #
  # So, for example we can select a variety of baseload metrics for each school, ordering
  # the overall list of metrics that are returned so that the school with the lowest
  # average annual baseload will be first in the results
  #
  # Note: this wont work if a metric has mixed values, e.g. integers/floats
  #
  # TODO: handle sorting of negative infinity, currently Float::NAN, Float::INFINITY, -Float::INFINITY are all
  # considered "high" values as the underlying sort is on the strings. May need to add a custom cast
  #
  # TODO: can we turn this into a single query?
  scope :order_by_school_metric_value, ->(metric_type, order = :desc) do
    school_ids = Comparison::Metric.for_latest_benchmark_runs.for_metric_type(metric_type).has_value.order(value: order).pluck(:school_id)
    order(Arel.sql("array_position(array#{school_ids}, comparison_metrics.school_id)"))
  end

  delegate :units, to: :metric_type
end
