require 'dashboard'

module Alerts
  class FrameworkAdapter
    attr_reader :analysis_date

    def initialize(alert_type:, school:, analysis_date: nil, aggregate_school:)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date || calculate_analysis_date
    end

    def analyse
      adapter_class(@alert_type).new(alert_type: @alert_type, school: @school, analysis_date: @analysis_date, aggregate_school: @aggregate_school).report
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
  end
end
