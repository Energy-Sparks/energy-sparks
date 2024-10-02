# frozen_string_literal: true

module Baseload
  class BaseloadAnnualBreakdownService < BaseService
    include AnalysableMixin

    def initialize(meter_collection)
      super()
      validate_meter_collection(meter_collection)
      @meter_collection = meter_collection
    end

    def annual_baseload_breakdowns
      @annual_baseload_breakdowns ||= calculate_annual_baseload_breakdowns
    end

    def enough_data?
      range_checker.at_least_x_days_data?(DEFAULT_DAYS_OF_DATA_REQUIRED)
    end

    def data_available_from
      enough_data? ? nil : range_checker.date_when_enough_data_available(DEFAULT_DAYS_OF_DATA_REQUIRED)
    end

    private

    def calculate_annual_baseload_breakdowns
      year_range.each_with_object([]) do |year, breakdowns|
        breakdowns << Baseload::AnnualBaseloadBreakdown.new(
          year: year,
          average_annual_baseload_kw: average_baseload_kw_for(year),
          meter_data_available_for_full_year: full_year_of_meter_data_for?(year)
        )
      end
    end

    def full_year_of_meter_data_for?(year)
      amr_data_start_and_end_date_range_covers?(Date.parse("01-01-#{year}")) &&
        amr_data_start_and_end_date_range_covers?(Date.parse("31-12-#{year}"))
    end

    def amr_data_start_and_end_date_range_covers?(date)
      date.between?(amr_data_start_date, amr_data_end_date)
    end

    def asof_date_for(year)
      Date.parse("31-12-#{year - 1}")
    end

    def average_baseload_kw_for(year)
      BaseloadAnalysis.new(aggregate_meter).average_annual_baseload_kw(asof_date_for(year))
    rescue StandardError
      nil
    end

    def aggregate_meter
      @aggregate_meter ||= @meter_collection.aggregated_electricity_meters
    end

    def amr_data_start_date
      @amr_data_start_date ||= aggregate_meter.amr_data.start_date
    end

    def amr_data_end_date
      @amr_data_end_date ||= aggregate_meter.amr_data.end_date
    end

    def year_range
      @year_range ||= (amr_data_start_date.year..amr_data_end_date.year).to_a
    end

    def range_checker
      meter_date_range_checker(aggregate_meter)
    end
  end
end
