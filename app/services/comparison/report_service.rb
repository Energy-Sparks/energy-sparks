module Comparison
  class ReportService
    def initialize(definition:)
      @definition = definition
    end

    def perform
      metrics = Comparison::Metric.for_latest_benchmark_runs.for_metric_type(
        Comparison::MetricType.where(key: @definition.metric_type_keys, fuel_type: @definition.fuel_types)
      ).with_metric_type.with_school.where(schools: @definition.schools).where(alert_type: @definition.alert_types).order_by_school_metric_value(
        Comparison::MetricType.find_by(key: @definition.order_key)
      )
      metrics_by_school = metrics.inject({}) do |hash, metric|
        if hash[metric.school]
          hash[metric.school] << metric
        else
          hash[metric.school] = [metric]
        end
        hash
      end
      return ReportResult.new(definition: @definition, metrics_by_school: metrics_by_school)
    end
  end
end
