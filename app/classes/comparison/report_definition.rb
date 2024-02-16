module Comparison
  class ReportDefinition
    attr_reader :report_key, :advice_page, :schools, :metric_type_keys, :alert_types, :fuel_types, :order_key

    def initialize(report_key:, advice_page:, schools:, metric_type_keys:, alert_types:, fuel_types:, order_key:)
      @report_key = report_key
      @advice_page = advice_page
      @schools = schools
      @metric_type_keys = metric_type_keys
      @alert_types = alert_types
      @fuel_types = fuel_types
      @order_key = order_key
    end
  end
end
