# frozen_string_literal: true

module Costs
  # Capable of generating a breakdown of tariff cost components for a specific meter
  # for a given month or range of months
  class MonthlyMeterCostsService
    include AnalysableMixin

    def initialize(meter:)
      @meter = meter
      @non_rate_types = %i[days start_date end_date first_day month]
    end

    # Calculate monthly cost breakdown for the previous year of data
    # Returns a hash of months => meter_month (or nil if no data for requested month)
    def calculate_costs_for_previous_twelve_months
      calculate_costs_for_months(months: previous_n_months(date: start_of_latest_month << 12))
    end

    # Calculate monthly cost breakdown for the latest year of data
    # Will cover 13 months (current month, plus 12 months prior)
    # Returns a hash of months => meter_month (or nil if no data for requested month)
    def calculate_costs_for_latest_twelve_months
      calculate_costs_for_months(months: previous_n_months(date: start_of_latest_month))
    end

    # Accepts array of months
    # Returns a hash of months => meter_month (or nil if no data for requested month)
    def calculate_costs_for_months(months:)
      months.each_with_object({}) do |month, monthly_billing|
        monthly_billing[month] = calculate_costs_for_month(month: month)
      end
    end

    # Calculate monthly cost breakdown for a specific month
    # Defaults to using the latest month of data, which might only have partial coverage
    def calculate_costs_for_month(month: start_of_latest_month)
      costs = cost_breakdown_for_month(month)
      return nil if costs.nil?

      create_meter_month(month: month, costs: costs)
    end

    # Can calculate as long as we have at least a month of data
    def enough_data?
      range_checker.at_least_x_days_data?(30)
    end

    private

    def create_meter_month(month:, costs:)
      Costs::MeterMonth.new(
        month_start_date: month,
        start_date: costs[:start_date],
        end_date: costs[:end_date],
        bill_component_costs: costs.except!(*@non_rate_types)
                                                    .transform_keys do |key|
                                                      key.to_s.parameterize.underscore.to_sym
                                                    end
      )
    end

    # return a hash of costs for that month
    def cost_breakdown_for_month(first_day_of_month)
      # if the end of the requested month is before start date, then we have no data
      return nil if DateTimeHelper.last_day_of_month(first_day_of_month) < @meter.amr_data.start_date
      # if the start of the requested month is after end date, then we have no data
      return nil if first_day_of_month > @meter.amr_data.end_date

      monthly_billing = create_monthly_billing_hash
      (first_day_of_month..DateTimeHelper.last_day_of_month(first_day_of_month)).each do |date|
        # skip if we dont have data for this day
        next unless @meter.amr_data.date_exists?(date)

        # fetch costs for this day
        bill_component_costs = @meter.amr_data.accounting_tariff.bill_component_costs_for_day(date)
        # add to the billing cost
        bill_component_costs.each do |bill_type, cost_in_pounds_sterling|
          monthly_billing[bill_type] += cost_in_pounds_sterling
        end
        # update the range covered
        monthly_billing[:start_date] = date unless monthly_billing.key?(:start_date)
        monthly_billing[:end_date]   = date
      end
      monthly_billing
    end

    def create_monthly_billing_hash
      Hash.new do |h, bill_component_types|
        h[bill_component_types] = 0.0
      end
    end

    def start_of_latest_month
      latest_data = @meter.amr_data.end_date
      Date.new(latest_data.year, latest_data.month, 1)
    end

    def previous_n_months(date: start_of_latest_month, months: 13)
      results = []
      months.times do |n|
        results << (date << n)
      end
      results.reverse
    end

    def range_checker
      @range_checker ||= Util::MeterDateRangeChecker.new(@meter, @meter.amr_data.end_date)
    end
  end
end
