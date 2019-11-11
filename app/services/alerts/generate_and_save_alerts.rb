module Alerts
  class GenerateAndSaveAlerts
    def initialize(school:, framework_adapter: FrameworkAdapter, aggregate_school: AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @alert_framework_adapter_class = framework_adapter
      @aggregate_school = aggregate_school
    end

    def perform
      @alert_generation_run = AlertGenerationRun.create!(school: @school)

      alerts_to_save = []
      alert_errors_to_save = []

      relevant_alert_types.each do |alert_type|
        generate(alert_type, alerts_to_save, alert_errors_to_save)
      end

      Alert.insert_all!(alerts_to_save) unless alerts_to_save.empty?
      AlertError.insert_all!(alert_errors_to_save) unless alert_errors_to_save.empty?
    end

  private

    def relevant_alert_types
      alert_types = AlertType.no_fuel
      alert_types.merge!(AlertType.electricity) if @school.has_electricity?
      alert_types.merge!(AlertType.gas) if @school.has_gas?
      alert_types.merge!(AlertType.storage_heater) if @school.has_storage_heaters?
      alert_types
    end

    def generate(alert_type, alerts_to_save, alert_errors_to_save)
      alert_framework_adapter = @alert_framework_adapter_class.new(alert_type: alert_type, school: @school, aggregate_school: @aggregate_school)
      asof_date = alert_framework_adapter.analysis_date

      alert_report = alert_framework_adapter.analyse

      if alert_report.valid
        alerts_to_save << build_alert(alert_report)
      else
        alert_errors_to_save << build_alert_error(alert_type, asof_date, "Relevance: #{alert_report.relevance}")
      end
    rescue => e
      Rails.logger.error "Exception: #{alert_type.class_name} for #{@school.name}: #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, school_id: @school.id, school_name: @school.name, alert_type: alert_type.class_name)

      alert_errors_to_save << build_alert_error(alert_type, asof_date, e.backtrace)
    end

    def build_alert_error(alert_type, asof_date, information)
      now = Time.zone.now

      {
        alert_generation_run_id: @alert_generation_run.id,
        asof_date: asof_date,
        alert_type_id: alert_type.id,
        information: information,
        created_at: now,
        updated_at: now
      }
    end

    def build_alert(analysis_report)
      now = Time.zone.now

      {
        school_id:                @school.id,
        alert_generation_run_id:  @alert_generation_run.id,
        alert_type_id:            @alert_type.id,
        run_on:                   @analysis_date,
        displayable:              analysis_report.displayable?,
        analytics_valid:          analysis_report.valid,
        rating:                   analysis_report.rating,
        enough_data:              analysis_report.enough_data,
        relevance:                analysis_report.relevance,
        template_data:            analysis_report.template_data,
        chart_data:               analysis_report.chart_data,
        table_data:               analysis_report.table_data,
        priority_data:            analysis_report.priority_data,
        created_at:               now,
        updated_at:               now
      }
    end
  end
end
