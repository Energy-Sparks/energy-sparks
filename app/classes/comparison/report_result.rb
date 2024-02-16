module Comparison
  class ReportResult
    attr_reader :definition, :metrics_by_school

    def initialize(definition:, metrics_by_school:)
      @definition = definition
      @metrics_by_school = metrics_by_school
    end

    def schools
      @metrics_by_school.keys
    end

    # Fetch a specific metric for a school based on its metric type key
    def metric(school, metric_type_key)
      return nil unless @metrics_by_school.key?(school)
      metrics = @metrics_by_school[school]
      metrics.detect {|m| m.metric_type.key.to_sym == metric_type_key}
    end

    # Find and use a metric. Avoids temporary assignments in templates
    def with_metric(school, metric_type_key)
      yield metric(school, metric_type_key)
    end

    # Find metric for a school and return its value formatted according to
    # its units
    def format_metric(school, metric_type_key)
      metric = metric(school, metric_type_key)
      return nil if metric.nil? || metric.value.nil?

      # No need for formatting
      # TODO: may need to consider formatting for some floats/integers
      if [:boolean, :string, :integer, :float].include?(metric.units.to_sym)
        metric.value
      else
        format(metric.value, metric.units.to_sym)
      end
    end

    # Format a calculated value with provided units
    def format(value, units)
      FormatEnergyUnit.format(units, zero_out_small_values(value), :html, false, true, :benchmark).html_safe
    end

    private

    # Ensure all tiny numbers are displayed as zero (e.g. -0.000000000000004736951571734001
    # should be shown as 0 and not -4.7e-15)
    def zero_out_small_values(value)
      return value unless value.is_a?(Float)
      value.between?(-0.001, 0.001) ? 0.0 : value
    end
  end
end
