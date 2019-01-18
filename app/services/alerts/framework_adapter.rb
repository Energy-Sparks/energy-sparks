require 'dashboard'

module Alerts
  class FrameworkAdapter
    def initialize(alert_type, school, aggregate_school, analysis_date)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date
    end

    def analyse
      analysis_report = alert_instance.new(@aggregate_school).analyse(@analysis_date)
      convert_to_alert(analysis_report)
    end

  private

    def alert_instance
      @alert_type.class_name.constantize
    end

    def convert_to_alert(analysis_report)
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
      }
    end
  end
end
