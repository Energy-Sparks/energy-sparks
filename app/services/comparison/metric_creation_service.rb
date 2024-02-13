module Comparison
  class MetricCreationService
    def initialize(benchmark_result_school_generation_run:, alert_type:, alert_report:, asof_date:)
      @benchmark_result_school_generation_run = benchmark_result_school_generation_run
      @alert_type = alert_type
      @alert_report = alert_report
      @asof_date = asof_date
      @analysis_object = alert_report.analysis_object
    end

    def perform
      return false if ignore_alert_type?
      # skip if not relevant to school, e.g. school doesn't have fuel tpe
      return false unless @analysis_object.valid_content?
      @alert_type.class_from_name.benchmark_template_variables.each do |key, definition|
        next if ignore_metric?(key)
        next unless metric_type(key, definition).present?
        # valid_content? && meter_readings_up_to_date_enough? && we want to store
        # this metric
        #
        # TODO: we could check for a value for this variable, rather than
        # whether there's any benchmark data available
        if @alert_report.valid && @alert_report.benchmark_data.present?
          Metric.create!(
            school: @benchmark_result_school_generation_run.school,
            benchmark_result_school_generation_run: @benchmark_result_school_generation_run,
            alert_type: @alert_type,
            metric_type: metric_type(key, definition),
            reporting_period: reporting_period(key, definition),
            enough_data: enough_data?,
            asof_date: @asof_date,
            whole_period: true, # TODO
            recent_data: @analysis_object.meter_readings_up_to_date_enough?,
            value: value(key, definition)
          )
        else
          # only here if we ran the alert but we didn't have enough data or data was
          # stale. Or there was an error. Storing empty metric so we can more
          # clearly identify which schools are missing in reports
          Metric.create!(
            school: @benchmark_result_school_generation_run.school,
            benchmark_result_school_generation_run: @benchmark_result_school_generation_run,
            alert_type: @alert_type,
            metric_type: metric_type(key, definition),
            reporting_period: reporting_period(key, definition),
            enough_data: enough_data?,
            asof_date: @asof_date,
            whole_period: true, # TODO how to determine?
            recent_data: @analysis_object.meter_readings_up_to_date_enough?,
            value: nil
          )
        end
      end
      true
    rescue => e
      puts e
      puts e.backtrace
      false
    end

    private

    # TODO formatting mappings, or handle in Metric?
    def value(key, _definition)
      @analysis_object.send(key)
    end

    # TODO other periods
    def reporting_period(_key, _definition)
      :last_12_months
    end

    # TODO check minimum?
    def enough_data?
      [:enough, :minimum_might_not_be_accurate].include?(@analysis_object.enough_data)
    end

    def metric_type(key, definition)
      MetricType.find_by(key: key, fuel_type: metric_fuel_type(key, definition))
    end

    def metric_fuel_type(key, definition)
      MetricMigrationService.new.fuel_type_for_metric_type(key, definition, @alert_type)
    end

    def ignore_alert_type?
      # Skip these until we have support for them
      return true if @alert_type.class_from_name.ancestors.include?(AlertArbitraryPeriodComparisonBase)
      false
    end

    def ignore_metric?(key)
      [:activation_date, :floor_area, :pupils, :school_name, :school_area, :school_type, :school_type_name, :urn, :degree_days_15_5C_domestic].include?(key)
    end
  end
end
