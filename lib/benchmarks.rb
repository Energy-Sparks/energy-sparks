module ExampleAnalytics
  def example_calculate_alerts(school, asof_date)
    AlertAnalysisBase.all_available_alerts.each do |alert_class|
      alert = alert_class.new(school)
      next if alert_class.benchmark_template_variables.empty?

      alert.benchmark_dates(asof_date).each do |benchmark_date|
        puts "Calculating alert for #{school.name} #{benchmark_date} #{alert_class}"
        next unless alert.valid_alert?

        alert.analyse(benchmark_date, true)
        puts "#{alert_class.name} failed" unless alert.calculation_worked
        next unless alert.make_available_to_users?

        save_benchmark_template_data(alert_class, alert, benchmark_date, school)
      end
    end
  end

  def example_save_benchmark_template_data(alert_class, alert, benchmark_date, school)
    new_data = alert.benchmark_template_data

    alert_short_code = alert_class.short_code
    new_data.each do |key, value|
      variable_short_code = alert_class.benchmark_template_variables[key][:benchmark_code]

      @database.add_value(benchmark_date, school.urn, alert_short_code, variable_short_code, value)
    end
  end
end
