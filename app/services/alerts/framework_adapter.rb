require 'dashboard'

module Alerts
  class FrameworkAdapter
    def initialize(alert_type:, school:, analysis_date: nil, aggregate_school:)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date || calculate_analysis_date
    end

    def analyse
      report = adapter_class(@alert_type).new(alert_type: @alert_type, school: @school, analysis_date: @analysis_date, aggregate_school: @aggregate_school).report
      build_alert(report)
    end

  private

    def adapter_class(alert_type)
      if alert_type.system?
        Adapters::SystemAdapter
      else
        Adapters::AnalyticsAdapter
      end
    end

    def calculate_analysis_date
      return Time.zone.today if @alert_type.fuel_type.nil?
      AggregateSchoolService.analysis_date(@aggregate_school, @alert_type.fuel_type)
    end

    def build_alert(analysis_report)
      Alert.new(
        school_id:        @school.id,
        alert_type_id:    @alert_type.id,
        run_on:           @analysis_date,
        displayable:      analysis_report.displayable?,
        analytics_valid:  analysis_report.valid,
        rating:           analysis_report.rating,
        enough_data:      analysis_report.enough_data,
        relevance:        analysis_report.relevance,
        template_data:    analysis_report.template_data,
        chart_data:       analysis_report.chart_data,
        table_data:       analysis_report.table_data,
        priority_data:    analysis_report.priority_data
      )
    end
  end
end
