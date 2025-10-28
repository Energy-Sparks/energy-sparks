# frozen_string_literal: true

module Usage
  class CombinedUsageMetricComparison
    def initialize(combined_usage_metric_latest, combined_usage_metric_previous)
      raise if combined_usage_metric_latest.class != CombinedUsageMetric
      raise if combined_usage_metric_previous.class != CombinedUsageMetric

      @combined_usage_metric_latest = combined_usage_metric_latest
      @combined_usage_metric_previous = combined_usage_metric_previous
    end

    def compare
      CombinedUsageMetric.new(
        kwh: (@combined_usage_metric_previous.kwh || 0) - (@combined_usage_metric_latest.kwh || 0),
        £: (@combined_usage_metric_previous.gbp || 0) - (@combined_usage_metric_latest.gbp || 0),
        co2: (@combined_usage_metric_previous.co2 || 0) - (@combined_usage_metric_latest.co2 || 0),
        percent: percent_change(@combined_usage_metric_previous.kwh, @combined_usage_metric_latest.kwh)
      )
    end

    private

    # Copied from ContentBase
    def percent_change(old_value, new_value)
      return nil if old_value.nil? || new_value.nil?
      return 0.0 if !old_value.nan? && old_value == new_value # both 0.0 case

      (new_value - old_value) / old_value
    end
  end
end
