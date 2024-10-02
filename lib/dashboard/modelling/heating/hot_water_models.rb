# Analyse heating, hot water and kitchen
module AnalyseHeatingAndHotWater
  #====================================================================================================================
  # HOT WATER ANALYSIS
  #
  # looks at DATE_MARGIN around the last summer holiday and calculate averages for weekends, holidays and school days
  # which is then used to extrapolated for the whole year
  class HotwaterModel
    include Logging

    HEATCAPACITYWATER = 4.2 # J/g/K
    PUPILUSAGELITRES = 5
    HWTEMPERATURE = 35.0 # C
    COLDWATERTEMPERATURE = 10.0
    BATHLITRES = 60
    SEASONALBOILEREFFICIENCY = 0.65
    DATE_MARGIN = 21
    # https://cms.esi.info/Media/documents/Stieb_SNU_ML.pdf

    attr_reader :buckets, :analysis_period, :efficiency
    attr_reader :analysis_period_start_date, :analysis_period_end_date
    attr_reader :annual_hotwater_kwh_estimate, :annual_hotwater_kwh_estimate_better_control
    attr_reader :avg_school_day_gas_consumption, :avg_holiday_day_gas_consumption, :avg_weekend_day_gas_consumption
    attr_reader :avg_school_day_open_kwh, :avg_school_day_closed_kwh
    attr_reader :annual_holiday_kwh, :annual_weekend_kwh, :annual_schoolday_open_kwh, :annual_schoolday_closed_kwh

    def initialize(meter_collection)
      @meter_collection = meter_collection
      @holidays = @meter_collection.holidays
      @school_day_kwh, @holiday_kwh, @weekend_kwh, @analysis_period, @first_holiday_date = analyse_hotwater_around_summer_holidays(meter_collection.holidays, meter_collection.aggregated_heat_meters)
      @efficiency = (@school_day_kwh - @holiday_kwh) / @school_day_kwh
      @analysis_period_start_date = @analysis_period.start_date
      @analysis_period_end_date = @analysis_period.end_date
      # logger.debug "Analysing hot water system efficiency school day use #{@school_day_kwh} holiday use #{@holiday_kwh} efficiency #{@efficiency}"
      # aggregate_split_day_buckets)archive
    end

    def kwh_daterange(start_date, end_date)
      total_useful_kwh = 0.0
      total_wasted_kwh = 0.0
      (start_date..end_date).each do |date|
        useful_kwh, wasted_kwh = kwh(date)
        total_useful_kwh += useful_kwh
        total_wasted_kwh += wasted_kwh
      end
      [total_useful_kwh, total_wasted_kwh]
    end

    def overall_efficiency
      efficiency * SEASONALBOILEREFFICIENCY
    end

    def self.benchmark_one_day_pupil_kwh
      HEATCAPACITYWATER * PUPILUSAGELITRES * (HWTEMPERATURE - COLDWATERTEMPERATURE) * 1_000.0 / 3_600_000.0
    end

    def self.annual_school_hot_water_litres(pupils)
      PUPILUSAGELITRES * 39 * 5 * pupils
    end

    def self.heat_capacity_water_kwh(litres, hot_water_temperature = HWTEMPERATURE, cold_water_temperature = COLDWATERTEMPERATURE)
      HEATCAPACITYWATER * litres * (hot_water_temperature - cold_water_temperature) * 1_000.0 / 3_600_000.0
    end

    def self.litres_of_hotwater(kwh)
      ((kwh * 3_600_000.0)/(HEATCAPACITYWATER * 1_000.0 * (HWTEMPERATURE - 10))).round(1)
    end

    def self.baths_of_hotwater(kwh)
      self.litres_of_hotwater(kwh).round(1) / BATHLITRES
    end

    def self.benchmark_annual_pupil_kwh
      39 * 5 * benchmark_one_day_pupil_kwh
    end

    def kwh(date)
      useful_kwh = 0.0
      wasted_kwh = 0.0
      todays_kwh = @meter_collection.aggregated_heat_meters.amr_data.one_day_kwh(date)

      if @holidays.holiday?(date) || DateTimeHelper.weekend?(date)
        wasted_kwh = todays_kwh
      elsif todays_kwh > @holiday_kwh
        wasted_kwh = @holiday_kwh
        useful_kwh = todays_kwh - @holiday_kwh
      else
        wasted_kwh = todays_kwh
      end
      [useful_kwh, wasted_kwh]
    end

    def daytype_breakdown_statistics
      results = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }

      results[:daily][:kwh]  = daily_kwh_averages
      results[:daily][:£]    = costs(results[:daily][:kwh])

      results[:annual][:kwh] = annual_kwh_daytype_breakdown(results[:daily][:kwh])
      results[:annual][:£]   = costs(results[:annual][:kwh])

      results
    end

    # the analysis relies on having hot water running exclusively before and during the holidays
    # this analysis won't work if these basic conditions aren't met
    def find_period_before_and_during_summer_holidays(holidays, amr_data)
      running_date = amr_data.end_date

      last_summer_hol = holidays.find_summer_holiday_before(running_date)

      return nil if last_summer_hol.nil?

      return nil if amr_data.end_date < last_summer_hol.start_date + DATE_MARGIN || amr_data.start_date > last_summer_hol.start_date - DATE_MARGIN

      [SchoolDatePeriod.new(:date_range, 'Summer Hot Water', last_summer_hol.start_date - DATE_MARGIN, last_summer_hol.start_date + DATE_MARGIN), last_summer_hol.start_date]
    end

    private

    def gas_price_£_per_kwh
      @meter_collection.aggregate_meter(:gas).amr_data.current_tariff_rate_£_per_kwh
    end

    # PH 12Oct2019: perhaps don't want costs in model?
    def costs(kwhs, energy_tariff_per_kwh = gas_price_£_per_kwh)
      kwhs.transform_values{ |kwh| kwh.nil? ? nil : kwh * energy_tariff_per_kwh }
    end

    def daily_kwh_averages
      {
        school_day_open:   avg_school_day_open_kwh,
        school_day_closed: avg_school_day_closed_kwh,
        holiday:          avg_holiday_day_gas_consumption,
        weekend:          avg_weekend_day_gas_consumption,
        total:            nil
      }
    end

    def annual_kwh_daytype_breakdown(daily_kwhs = daily_kwh_averages)
      weeks_holiday = 13
      school_weeks  = 52 - weeks_holiday

      annual_kwh = {
        school_day_open:   daily_kwhs[:school_day_open]   * school_weeks  * 5,
        school_day_closed: daily_kwhs[:school_day_closed] * school_weeks  * 5,
        holiday:          daily_kwhs[:holiday]          * weeks_holiday * 7,
        weekend:          daily_kwhs[:weekend]          * school_weeks  * 2,
      }

      annual_kwh[:total] = annual_kwh.values.sum

      annual_kwh
    end

    def average_kwhs(arr)
      return 0.0 if arr.empty?
      arr.sum / arr.length
    end

    def categorise_single_day_hot_water(data, during_holidays, date, amr_data)
      if during_holidays && !DateTimeHelper.weekend?(date)
        data[:holiday_kwhs].push(amr_data.one_day_kwh(date))
      elsif DateTimeHelper.weekend?(date)
        data[:weekend_kwhs].push(amr_data.one_day_kwh(date))
      else
        open_kwh, close_kwh = intra_schoolday_breakdown(amr_data, date)
        data[:school_day_open_kwhs].push(open_kwh)
        data[:school_day_closed_kwhs].push(close_kwh)
      end
    end

    def intra_schoolday_breakdown(amr_data, date)
      # optimal to start and end hot water 1 hour before school open/close
      hot_water_start_time  = TimeOfDay.add_hours_and_minutes(@meter_collection.open_time,  -1)
      hot_water_end_time    = TimeOfDay.add_hours_and_minutes(@meter_collection.close_time, -1)

      hotwater_time_vector_x48 = DateTimeHelper.weighted_x48_vector_multiple_ranges([hot_water_start_time..hot_water_end_time])

      open_kwh_x48 = AMRData.fast_multiply_x48_x_x48(amr_data.days_kwh_x48(date, :kwh), hotwater_time_vector_x48)

      open_kwh = open_kwh_x48.sum
      close_kwh = amr_data.one_day_kwh(date) - open_kwh

      [open_kwh, close_kwh]
    end

    def analyse_hotwater_around_summer_holidays(holidays, meter)
      analysis_period, first_holiday_date = find_period_before_and_during_summer_holidays(holidays, meter.amr_data)

      raise EnergySparksNotEnoughDataException, 'Meter data does not cover a period starting before and including a sumer holiday - unable to complete hot water efficiency analysis' if analysis_period.nil?

      data = %i[holiday_kwhs weekend_kwhs school_day_open_kwhs school_day_closed_kwhs].map { |daytype| [daytype, []] }.to_h

      (analysis_period.start_date..analysis_period.end_date).each do |date|
        categorise_single_day_hot_water(data, date >= first_holiday_date, date, meter.amr_data)
      end

      set_aggregate_values(data)

      [@avg_school_day_gas_consumption, @avg_holiday_day_gas_consumption, @avg_weekend_day_gas_consumption, analysis_period, first_holiday_date]
    end

    def set_aggregate_values(data)
      set_average_daily_consumptions(data)
      set_annual_estimates
    end

    def set_average_daily_consumptions(data)
      @avg_school_day_open_kwh = average_kwhs(data[:school_day_open_kwhs])
      @avg_school_day_closed_kwh = average_kwhs(data[:school_day_closed_kwhs])
      @avg_school_day_gas_consumption   = @avg_school_day_open_kwh + @avg_school_day_closed_kwh
      @avg_holiday_day_gas_consumption  = average_kwhs(data[:holiday_kwhs])
      @avg_weekend_day_gas_consumption  = average_kwhs(data[:weekend_kwhs])
    end

    def set_annual_estimates
      weeks_holiday = 13
      school_weeks = 52 - weeks_holiday
      @annual_holiday_kwh = avg_holiday_day_gas_consumption * weeks_holiday * 7
      @annual_weekend_kwh = avg_weekend_day_gas_consumption * school_weeks * 2
      @annual_schoolday_open_kwh = avg_school_day_open_kwh * school_weeks * 5
      @annual_schoolday_closed_kwh = avg_school_day_closed_kwh * school_weeks * 5

      @annual_hotwater_kwh_estimate = [annual_holiday_kwh, annual_weekend_kwh, annual_schoolday_open_kwh, annual_schoolday_closed_kwh].sum
      @annual_hotwater_kwh_estimate_better_control = annual_schoolday_open_kwh
    end

  end
end
