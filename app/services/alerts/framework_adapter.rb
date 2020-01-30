require 'dashboard'

module Alerts
  class FrameworkAdapter
    attr_reader :analysis_date

    def initialize(alert_type:, school:, analysis_date: nil, aggregate_school:, use_max_meter_date_if_less_than_asof_date: false)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date || calculate_analysis_date
      @use_max_meter_date_if_less_than_asof_date = use_max_meter_date_if_less_than_asof_date
    end

    def analyse
      adapter_instance.report
    end

    def content(user_type = nil)
      adapter_instance.content(user_type)
    end

    def has_structured_content?
      adapter_instance.has_structured_content?
    end

    def structured_content
      adapter_instance.structured_content
    end

    def benchmark_dates
      adapter_instance.benchmark_dates
    end

  private

    def adapter_instance
      adapter_class(@alert_type).new(alert_type: @alert_type, school: @school, analysis_date: @analysis_date, aggregate_school: @aggregate_school, use_max_meter_date_if_less_than_asof_date: @use_max_meter_date_if_less_than_asof_date)
    end

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
