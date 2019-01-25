require 'dashboard'

module Alerts
  class FrameworkAdapter
    def initialize(alert_type, school, analysis_date, aggregate_school = AggregateSchoolService.new(school).aggregate_school)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date
    end

    def analyse
      begin
        analysis_report = alert_instance.new(@aggregate_school).analyse(@analysis_date)
      rescue NoMethodError
        analysis_report = AlertReport.new(@alert_type)
        analysis_report.summary = "There was a problem running this alert: #{@alert_type.title}."
        analysis_report.rating = nil
        Rails.logger.error("There was a problem running #{@alert_type.title} for #{@analysis_date} and #{@school.name}")
      end
      build_alert(analysis_report)
    end

  private

    def alert_instance
      @alert_type.class_name.constantize
    end

    def build_alert(analysis_report)
      Alert.new(
        school_id: @school.id,
        alert_type_id: @alert_type.id,
        run_on: @analysis_date,
        status: analysis_report.status,
        summary: analysis_report.summary,
        data: data_hash(analysis_report),
      )
    end

    def data_hash(analysis_report)
      {
        help_url: analysis_report.help_url,
        detail: analysis_report.detail,
        rating: analysis_report.rating,
        type: analysis_report.type,
        term: analysis_report.term
      }
    end
  end
end
