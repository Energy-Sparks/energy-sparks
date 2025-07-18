# test alerts
require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require_relative '../script/report_config_support.rb'
require 'hashdiff'

class RunAlerts < RunAnalyticsTest
  def initialize(school)
    super(school, results_sub_directory_type: self.class.test_type)
    @@class_methods_run ||= []
  end

  def self.test_type
    'Alerts'
  end

  def self.default_config
    self.superclass.default_config.merge({ alerts: self.alerts_default_config })
  end

  def self.alerts_default_config
    {
      no_alerts:   [ AlertSchoolWeekComparisonGas ], #,  AlertCommunitySchoolWeekComparisonElectricity  AlertCommunityPreviousHolidayComparisonGas,
      alerts: nil,
      control:  {
                  compare_results: {
                    summary:              :differences, # true || false || :detail || :differences
                    report_if_differs:    true,
                    methods:              %i[raw_variables_for_saving front_end_template_data html_template_variables],   # %i[ raw_variables_for_saving front_end_template_data front_end_template_chart_data front_end_template_table_data
                    class_methods:        %i[front_end_template_variables],
                  },

                  no_outputs: %i[raw_variables_for_saving],
                  log: %i[],

                  no_save_priority_variables:  { filename: './TestResults/alert priorities.csv' },
                  no_benchmark:          %i[school alert ], # detail],
                }
    }
  end

  def self.run_heating_on_alert_seasonal_tests(asof_date, schools_list)
    seasonal_test_datesand_temperatures(asof_date).map do |config|
      {
          schools:  schools_list,
          alerts:   {
            alerts: [ AlertTurnHeatingOff ],
            control: {
              asof_date:  config[:asof_date],
              forecast:   config[:forecast]
            },
          }
        }
      end
  end

  def self.seasonal_test_datesand_temperatures(asof_date)
    y = asof_date.year
    dates =        [ Date.new(y, 7, 1), Date.new(y, 10, 1), Date.new(y, 2, 1), Date.new(y, 5, 1) ]
    temperatures = [ 20.0,              15.0,               5.0,                18.0 ]
    dates.map.with_index do |date, i|
      config = {
        asof_date: date > asof_date ? Date.new(date.year - 1, date.month, date.day) : date,
        forecast: { temperature: temperatures[i] }
      }
    end
  end

  def run(alerts, control, asof_date)
    ENV['ENERGYSPARKSTODAY'] = asof_date.to_s # allow constructor to know run date

    alerts = AlertAnalysisBase.all_available_alerts if alerts.nil?

    @excel_tab_names = class_names_to_excel_tab_names(alerts)

    set_forecast(control[:forecast], asof_date)

    alerts.sort_by(&:name).each do |alert_class|

      alert = alert_class.new(@school)

      unless alert.meter_readings_up_to_date_enough?
        log_result(alert, 'Meter out of date') # not stored for stats as code runs on to subsequent call in loop
      end

      unless alert.valid_alert?
        log_result(alert, 'Invalid alert before analysis', control[:log].include?(:invalid_alerts))
        next
      end
=begin
      if alert.relevance == :never_relevant
        log_result(alert, 'Never relevant')
        next
      end

      if alert.enough_data == :not_enough
        log_result(alert, 'not enough data')
        next
      end
=end
      RecordTestTimes.instance.record_time(@school.name, 'alerts', alert.class.name){
        alert.analyse(asof_date, true)
      }

      check_charts(alert_class, alert, control, asof_date) if control.dig(:charts, :calculate) == true

      print_results(alert_class, alert, control[:outputs])

      html = alert.format_variables_as_html

      save_formatted_results(alert.class.name, html)

      save_to_yaml_and_compare_results(alert_class, alert, control, asof_date)
      save_class_methods_to_yaml_and_compare_results(alert_class, alert, control, asof_date)

      log_results(alert, control)

      save_to_excel if control.dig(:charts, :write_to_excel) == true

      unset_forecast
    rescue => e
      log_result(alert, "Crashed: #{e.message} #{e.backtrace[0]}")
    end
  end

  def save_formatted_results(type, html)
    filename = "Alerts - #{type}.html"
    html_file = HtmlFileWriter.new(filename, results_sub_directory_type: @results_sub_directory_type)
    html_file.write_header_footer('', html, nil)
    html_file.close
  end

  private

  def excel_variation
    '- alerts charts test'
  end

  def save_class_methods_to_yaml_and_compare_results(alert_class, alert, control, asof_date)
    control[:compare_results][:class_methods].each do |method|
      comparison = CompareContent2.new(alert_class.name, control, results_sub_directory_type: @results_sub_directory_type)
      name = "#{alert_class.name} #{method}"
      unless @@class_methods_run.include?(name)
        comparison.save_and_compare(name, method_call_results(alert_class, alert, method))
        @@class_methods_run.push(name)
      end
    end
  end

  def save_to_yaml_and_compare_results(alert_class, alert, control, asof_date)
    results = control[:compare_results][:methods].map do |method|
      [method, method_call_results(alert_class, alert, method) ]
    end.to_h

    compare_results(control, alert_class.name, results, asof_date)
  end

  def print_results(alert_class, alert, methods)
    return if methods.nil?

    print_banner(alert_class.name.to_s)
    methods.each do |method|
      ap method_call_results(alert_class, alert, method)
    end
  end

  def method_call_results(alert_class, alert, method)
    if alert.respond_to?(method)
      alert.public_send(method)
    else
      alert_class.public_send(method)
    end
  end

  def log_results(alert, control)
    msg = error_message(alert)
    if msg.nil?
      unless alert.make_available_to_users?
        log_result(alert, 'Not make_available_to_users after analysis')
      else
        log_result(alert, 'Calculated succesfully', control[:log].include?(:sucessful_calculations))
      end
    else
      log_result(alert, msg)
    end
  end

  def error_message(alert)
    return nil if alert.error_message.nil?
    "#{alert.error_message}: #{alert.backtrace.first.split('/').last}"
  end

  def log_result(alert, message, print = true)
    puts "#{sprintf('%-50.50s', alert.class.name)} #{message}" if print
    RecordTestTimes.instance.log_calculation_status(@school.name, 'alerts', alert.class.name, message)
  end

  def run_charts(alert)
    return if alert.front_end_template_chart_data.empty?

    alert.front_end_template_chart_data.values.map do |chart_name|
      [
        chart_name,
        run_chart(@excel_tab_names[alert.class], chart_name.to_sym)
      ]
    end.to_h
  end

  def check_charts(alert_class, alert, control, asof_date)
    results = nil

    RecordTestTimes.instance.record_time(@school.name, 'alerts: charts', alert.class.name){
      results = run_charts(alert)
    }

    return if results.nil?

    chart_results = results.transform_keys{ |k| "chart_#{k}".to_sym }

    compare_results(control, alert_class.name, chart_results, asof_date)
  end

  # pass test forecast through as environment variables so the production,
  # front end code doesn't know about this interface being passed through
  def set_forecast(forecast, asof_date)
    return if forecast.nil?

    dates = {
      start_date: forecast[:start_date] || asof_date,
      end_date:   forecast[:end_date]   || asof_date + 14
    }

    ENV['ENERGYSPARKSFORECAST'] = YAML.dump(forecast.merge(dates))
  end

  def unset_forecast
    ENV.delete('ENERGYSPARKSFORECAST')
  end
end
