module Comparison
  class ReportDefinition
    attr_reader :report_key, :advice_page, :schools, :metric_type_keys, :alert_types, :fuel_types, :order_key, :order

    def initialize(metric_type_keys:, order_key:, schools: [], report_key: nil, alert_types: nil, fuel_types: nil, advice_page: nil, order: :desc)
      @report_key = report_key
      @advice_page = advice_page
      @schools = schools
      @metric_type_keys = metric_type_keys
      @alert_types = alert_types
      @fuel_types = fuel_types
      @order_key = order_key
      @order = order
    end
  end
end
