module Comparison
  class MetricCreationService
    def initialize(benchmark_result_school_generation_run:, alert_type:, alert_report:, asof_date:)
      @benchmark_result_school_generation_run = benchmark_result_school_generation_run
      @school = @benchmark_result_school_generation_run.school
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

        if @alert_report.valid && @alert_report.benchmark_data.present?
          # valid_content? && meter_readings_up_to_date_enough? && we want to store
          # this metric
          #
          # We could check for a value for this variable, rather than
          # whether there's any benchmark data available
          value = @analysis_object.send(key)
        else
          # Reach here if we ran the alert but we didn't have enough data, the data was
          # stale, or there was an error. Storing empty metric so we can more
          # clearly identify which schools are missing which data in reports.
          value = nil
        end
        Metric.create!(
          school: @school,
          benchmark_result_school_generation_run: @benchmark_result_school_generation_run,
          alert_type: @alert_type,
          metric_type: metric_type(key, definition),
          reporting_period: reporting_period(key, definition),
          enough_data: enough_data?,
          asof_date: @asof_date,
          whole_period: true, # TODO will need revisiting when we add arbitrary period metrics
          recent_data: @analysis_object.meter_readings_up_to_date_enough?,
          value: value
        )
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :metric_creation, school_id: @school.id, school: @school.name, alert_type: @alert_type.class_name)
      false
    end

    private

    def reporting_period(_key, _definition)
      # alternative approach would be to add class methods in analytics, but this
      # keeps the mappings in the application and provides a useful overview
      case @alert_type.class_name
      when 'AlertSchoolWeekComparisonElectricity', 'AlertSchoolWeekComparisonGas'
        :last_2_school_weeks
      when 'AlertPreviousHolidayComparisonElectricity', 'AlertPreviousHolidayComparisonGas'
        :last_2_holidays
      when 'AlertPreviousYearHolidayComparisonElectricity', 'AlertPreviousYearHolidayComparisonGas'
        :last_holiday_and_previous_year
      when 'AlertElectricityUsageDuringCurrentHoliday', 'AlertGasHeatingHotWaterOnDuringHoliday'
        :current_holiday
      else
        # all others are for last 12 months, including AlertImpendingHoliday
        :last_12_months
      end
    end

    def enough_data?
      @analysis_object.enough_data == :enough
    end

    def metric_type(key, definition)
      MetricType.find_by(key: key_for_metric_type(key), fuel_type: metric_fuel_type(key, definition))
    end

    def metric_fuel_type(key, definition)
      MetricMigrationService.new.fuel_type_for_metric_type(key, definition, @alert_type)
    end

    def ignore_alert_type?
      # Skip these until we have support for them
      return true if @alert_type.class_from_name.ancestors.include?(AlertArbitraryPeriodComparisonBase)
      false
    end

    def key_for_metric_type(key)
      MetricMigrationService.new.key_for_metric(@alert_type, key)
    end

    def ignore_metric?(key)
      # This alert has dynamically defined accessors, but tracks what's missing, so need to check
      # if there's actually data
      if @alert_type.class_name == 'AlertEnergyAnnualVersusBenchmark'
        return @analysis_object.instance_variable_get(:@missing_variables).include?(key)
      end
      [:activation_date, :floor_area, :pupils, :school_name, :school_area, :school_type, :school_type_name, :urn, :degree_days_15_5C_domestic].include?(key)
    end
  end
end
