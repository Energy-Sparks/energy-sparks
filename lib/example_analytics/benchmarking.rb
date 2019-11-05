module ExampleAnalytics
  class Benchmarking
    def initialize(active_record_school = School.first, asof_date = Date.yesterday)
      @school = aggregate_school(active_record_school)
      @asof_date = asof_date
      @output_hash = {}
    end

    def aggregate_school(active_record_school)
      AggregateSchoolService.new(active_record_school).aggregate_school
    end

    def example_calculate_alerts
      AlertAnalysisBase.all_available_alerts.each do |alert_class|
        alert = alert_class.new(@school)
        next if alert_class.benchmark_template_variables.empty?

        alert.benchmark_dates(@asof_date).each do |benchmark_date|
          puts "Calculating alert for #{@school.name} #{benchmark_date} #{alert_class}"
          next unless alert.valid_alert?

          alert.analyse(benchmark_date, true)
          puts "#{alert_class.name} failed" unless alert.calculation_worked
          next unless alert.make_available_to_users?

          example_save_benchmark_template_data(alert_class, alert, benchmark_date)
        end
      end

      @output_hash
    end

    def example_save_benchmark_template_data(alert_class, alert, benchmark_date)
      new_data = alert.benchmark_template_data

      alert_short_code = alert_class.short_code
      new_data.each do |key, value|
        variable_short_code = alert_class.benchmark_template_variables[key][:benchmark_code]

        pp "#{benchmark_date} #{@school.name} #{alert_short_code} #{variable_short_code} #{value}"

        #@database.add_value(benchmark_date, school.urn, alert_short_code, variable_short_code, value)
      end

      @output_hash[benchmark_date] = new_data
    end
  end
end
