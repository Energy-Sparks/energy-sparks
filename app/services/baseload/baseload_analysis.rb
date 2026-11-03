# frozen_string_literal: true

module Baseload
  # mix of electricity baseload analysis
  class BaseloadAnalysis
    HOURS_IN_YEAR = 24.0 * 365.0
    def initialize(meter)
      @meter = meter
    end

    def baseload_kw(date, data_type = :kwh)
      calculator.baseload_kw(date, data_type)
    end

    def average_baseload_kw(date1, date2)
      calculator.average_baseload_kw_date_range(date1, date2)
    end

    def average_baseload_last_week_kw(date)
      average_baseload_kw(one_week_ago(date), date)
    end

    def average_annual_baseload_kw(asof_date)
      start_date, end_date, _scale_to_year = scaled_annual_dates(asof_date)
      average_baseload_kw(start_date, end_date)
    end

    def annual_average_baseload_kwh(asof_date)
      @annual_average_baseload_kwh ||= {}
      @annual_average_baseload_kwh[asof_date] ||= 365.0 * 24.0 * average_annual_baseload_kw(asof_date)
    end

    def baseload_percent_annual_consumption(asof_date)
      baseload_kwh = annual_average_baseload_kwh(asof_date)

      start_date, end_date, scale_to_year = scaled_annual_dates(asof_date)
      kwh = @meter.amr_data.kwh_date_range(start_date, end_date, :kwh) * scale_to_year
      return 0.0 if kwh.zero?

      baseload_kwh / kwh
    end

    def scaled_annual_baseload_cost_£(datatype, asof_date = amr_data.end_date)
      start_date, end_date, scale_to_year = scaled_annual_dates(asof_date)
      baseload_economic_cost_date_range_£(start_date, end_date, datatype) * scale_to_year
    end

    def blended_baseload_tariff_rate_£_per_kwh(datatype, asof_date = amr_data.end_date)
      annual_average_baseload_kwh = annual_average_baseload_kwh(asof_date)
      return 0.0 if annual_average_baseload_kwh.zero?

      scaled_annual_baseload_cost_£ = scaled_annual_baseload_cost_£(datatype, asof_date)
      scaled_annual_baseload_cost_£ / annual_average_baseload_kwh
    end

    def one_years_data?(asof_date = amr_data.end_date)
      start_date = @meter.amr_data.start_date
      (asof_date - 364) >= start_date
    end

    def self.scale_to_year(start_date, end_date)
      (365 / (end_date - start_date + 1)).to_f
    end

    def scaled_annual_dates(asof_date)
      end_date = [asof_date, amr_data.end_date].min
      start_date = [end_date - 364, amr_data.start_date].max
      [start_date, end_date, self.class.scale_to_year(start_date, end_date)]
    end

    # We use 6 rather than 7 days ago because of potential issue with schools
    # with large intraweek variation in consumption.
    def one_week_ago(date)
      date - 6
    end

    def baseload_co2_carbon_intensity_co2_k2_per_kwh(asof_date = amr_data.end_date)
      end_date = [asof_date, amr_data.end_date].min
      start_date = [end_date - 364, amr_data.start_date].max
      @meter.meter_collection.grid_carbon_intensity.average_in_date_range(start_date, end_date)
    end

    def one_years_baseload_co2_kg(asof_date = amr_data.end_date)
      HOURS_IN_YEAR * baseload_co2_carbon_intensity_co2_k2_per_kwh(asof_date)
    end

    def baseload_economic_cost_date_range_£(date1, date2, datatype)
      (date1..date2).map do |date|
        baseload_economic_cost_£(date, datatype)
      end.sum
    end

    def winter_kw(asof_date = amr_data.end_date)
      average_top_n(baseload_kws_for_dates(winter_school_day_sample_dates(asof_date)), 15)
    end

    def summer_kw(asof_date = amr_data.end_date)
      average_bottom_n(baseload_kws_for_dates(summer_school_day_sample_dates(asof_date)), 15)
    end

    def percent_seasonal_variation(asof_date = amr_data.end_date)
      return nil unless one_years_data?

      kw_in_summer = summer_kw(asof_date)
      return 0.0 if kw_in_summer.zero? # Otherwise the division (by zero) below will return Infinity

      (winter_kw(asof_date) - kw_in_summer) / kw_in_summer
    end

    def average_intraweek_schoolday_kw(asof_date = amr_data.end_date)
      return nil unless one_years_data?

      weekday_baseloads = weekday_baseloads_kw(asof_date)

      weekday_baseloads.transform_values do |kws|
        kws.sum / kws.length
      end
    end

    def costs_of_baseload_above_minimum_kwh(asof_date, minimum)
      baseloads_kw = years_baseloads(asof_date)
      excess_of_minimum_kws = baseloads_kw.map { |kw| [kw - minimum, 0.0].max }
      excess_of_minimum_kws.sum * 24.0 # convert to kWh
    end

    private

    def baseload_economic_cost_£(date, datatype)
      baseload_economic_cost_x48(date, datatype).sum
    end

    def baseload_economic_cost_x48(date, datatype)
      blended_rate_£_per_kwh_x48 = amr_data.blended_rate_£_per_kwh_x48(date, datatype)
      baseload_kwh_x48 = AMRData.single_value_kwh_x48(baseload_kw(date) / 2.0)
      AMRData.fast_multiply_x48_x_x48(baseload_kwh_x48, blended_rate_£_per_kwh_x48)
    end

    def years_baseloads(asof_date)
      statistical_baseloads_in_date_range(up_to_a_year_ago(asof_date), amr_data.end_date)
    end

    def statistical_baseloads_in_date_range(start_date, end_date)
      (start_date..end_date).to_a.map { |d| amr_data.statistical_baseload_kw(d) }
    end

    def baseload_kws_for_dates(dates)
      dates.map { |d| baseload_kw(d) }
    end

    def average_top_n(baseload_kws, num)
      kws = baseload_kws.sort.last(num)
      kws.sum / kws.length
    end

    def average_bottom_n(baseload_kws, num)
      kws = baseload_kws.sort.first(num)
      kws.sum / kws.length
    end

    def summer_school_day_sample_dates(asof_date)
      sample_days_in_months(asof_date, [5, 6, 7])
    end

    def winter_school_day_sample_dates(asof_date)
      sample_days_in_months(asof_date, [11, 12, 1, 2])
    end

    def sample_days_in_months(asof_date, months_list, type = :schoolday)
      sample_dates = []
      (up_to_a_year_ago(asof_date)..amr_data.end_date).each do |date|
        sample_dates.push(date) if months_list.include?(date.month) && daytype(date) == type
      end
      sample_dates
    end

    def weekday_baseloads_kw(asof_date)
      weekday_baseloads = {}
      (up_to_a_year_ago(asof_date)..amr_data.end_date).each do |date|
        next if daytype(date) == :holiday

        weekday_baseloads[date.wday] ||= []
        weekday_baseloads[date.wday].push(baseload_kw(date))
      end
      weekday_baseloads
    end

    def up_to_a_year_ago(asof_date)
      [asof_date - 364, amr_data.start_date].max
    end

    def daytype(date)
      DateTimeHelper.daytype(date, @meter.meter_collection.holidays)
    end

    def amr_data
      @meter.amr_data
    end

    def calculator
      @calculator ||= BaseloadCalculator.calculator_for(@meter.amr_data, @meter.solar_pv_panels?)
    end
  end
end
