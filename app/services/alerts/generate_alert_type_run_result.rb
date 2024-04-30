module Alerts
  class GenerateAlertTypeRunResult
    def initialize(
        school:,
        alert_type:,
        framework_adapter: FrameworkAdapter,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school,
        use_max_meter_date_if_less_than_asof_date: false
      )
      @school = school
      @alert_framework_adapter_class = framework_adapter
      @aggregate_school = aggregate_school
      @alert_type = alert_type
      @use_max_meter_date_if_less_than_asof_date = use_max_meter_date_if_less_than_asof_date
    end

    def perform(asof_date = nil)
      generate_alert_report(asof_date)
    end

    def benchmark_dates(asof_date)
      alert_framework_adapter(asof_date).benchmark_dates
    end

    private

    def alert_framework_adapter(asof_date)
      @alert_framework_adapter_class.new(alert_type: @alert_type, school: @school, aggregate_school: @aggregate_school, analysis_date: asof_date, use_max_meter_date_if_less_than_asof_date: @use_max_meter_date_if_less_than_asof_date)
    end

    def generate_alert_report(asof_date)
      afa = alert_framework_adapter(asof_date)
      AlertTypeRunResult.generate_alert_report(@alert_type, afa.analysis_date, @school) do
        afa.analyse
      end
    end
  end
end
