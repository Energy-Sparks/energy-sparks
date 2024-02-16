module Comparison
  class ReportService
    def initialize(definition:)
      @definition = definition
    end

    def perform
      fuel_types = @definition.fuel_types || Comparison::MetricType.fuel_types.keys
      alert_types = @definition.alert_types || AlertType.enabled

      metric_types = Comparison::MetricType.where(key: @definition.metric_type_keys, fuel_type: fuel_types)
      order_type = Comparison::MetricType.find_by(key: @definition.order_key)

      metrics = Comparison::Metric
                  .for_latest_benchmark_runs     # only load metrics for latest benchmark run per school
                  .for_metric_type(metric_types) # fetch these metric types
                  .where(schools: @definition.schools, alert_type: alert_types) # for schools and alerts
                  .with_school_and_metric_type # include the school and metric type to avoid n+1 queries
                  .order_by_school_metric_value(order_type, @definition.order) # apply custom order

      # Ruby preserved order when iterating on a hash, so this allows us to
      # iterate over this hash and access metrics for each school whilst preserving
      # the order from the SQL query
      metrics_by_school = metrics.inject({}) do |hash, metric|
        hash[metric.school] ||= []
        hash[metric.school].push(metric)
        hash
      end

      return ReportResult.new(definition: @definition, metrics_by_school: metrics_by_school)
    end
  end
end
