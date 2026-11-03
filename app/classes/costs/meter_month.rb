# frozen_string_literal: true

module Costs
  class MeterMonth
    attr_reader :month_start_date, :start_date, :end_date, :first_day, :bill_component_costs

    def initialize(month_start_date:, start_date: nil, end_date: nil, bill_component_costs: nil)
      @month_start_date = month_start_date
      @start_date = start_date
      @end_date = end_date
      @bill_component_costs = bill_component_costs
    end

    def total
      bill_component_costs.values.sum
    end

    def full_month
      days_in_month == days
    end

    def days
      (end_date - start_date).to_i + 1
    end

    private

    def days_in_month
      Date.new(month_start_date.year, month_start_date.month, -1).day
    end
  end
end
