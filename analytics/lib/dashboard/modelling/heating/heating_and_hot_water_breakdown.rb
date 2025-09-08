module AnalyseHeatingAndHotWater

  # An attempt to analyse the breakdown between heating, hot water and kitchen
  # usage at a school, works on gas only
  class HeatingAndHotWaterBreakdown
    def initialize(school)
      @school = school
    end

    # a +tve change_in_degree_days_percent indicates the adjusted temperature is lower i.e. colder
    # and therefore the adjusted kWh should be more than actual kWh
    def breakdown(start_date: nil, end_date: nil, change_in_degree_days_percent: 0.0)
      return nil if !@school.gas? || @school.aggregated_heat_meters.non_heating_only?
      end_date = @school.aggregated_heat_meters.amr_data.end_date if end_date.nil?
      start_date = [end_date - 365, @school.aggregated_heat_meters.amr_data.start_date].max

      heating_only_meter = @school.aggregated_heat_meters.heating_only?

      hot_water_model = HotwaterModel.new(@school)
      hot_water_efficiency = hot_water_model.overall_efficiency

      total_kwh = 0.0
      adjusted_kwh = 0.0
      hot_water_winter_kwh = 0.0
      hot_water_summer_kwh = 0.0

      @model_cache = AnalyseHeatingAndHotWater::ModelCache.new(@school.aggregated_heat_meters)
      one_year_meter_readings = SchoolDatePeriod.new(:current_year, '1 year model calculation', start_date, end_date)

      begin
        @heating_model = @model_cache.create_and_fit_model(:best, one_year_meter_readings)
      rescue EnergySparksNotEnoughDataException => _e
        return nil
      end
      (start_date..end_date).each do |date|
        actual_usage_kwh = @school.aggregated_heat_meters.amr_data.one_day_kwh(date)
        temperature = @school.temperatures.average_temperature(date)
        heating_on = @heating_model.heating_on?(date)
        model_type = @heating_model.model_type?(date)
        model = @heating_model.model(model_type)
        if heating_on
          degree_days = [15.5 - temperature, 0].max
          temperature_adjustment_as_a_percent_of_degree_days = degree_days * change_in_degree_days_percent
          # the * -1 is because this is a degree day adjustment to a more which works in temperature
          # space ie. one is the -tive of the other
          adjustment = temperature_adjustment_as_a_percent_of_degree_days * model.b * -1.0
          adjusted_kwh += actual_usage_kwh + adjustment

          unless heating_only_meter
            summer_model_type = @heating_model.summer_model(date)
            # in the winter, calculate the hw consumption purely from the summer model
            if @heating_model.model(summer_model_type).nil?
              puts "Warning no summer model on #{date}"
            else
              predicted_hw_usage_kwh = @heating_model.model(summer_model_type).predicted_kwh_temperature(temperature)
              hot_water_winter_kwh += predicted_hw_usage_kwh
            end
          end
        else
          adjusted_kwh += actual_usage_kwh
          hot_water_summer_kwh += actual_usage_kwh
        end
        total_kwh += actual_usage_kwh
      end

      hw_analysis = @heating_model.hot_water_analysis(start_date, end_date)

      percent = (total_kwh - adjusted_kwh) / total_kwh

      percent_hw = (hot_water_winter_kwh + hot_water_summer_kwh) / total_kwh

      results = {
        hot_water_summer_all_days_kwh:    hot_water_summer_kwh,
        hot_water_winter_all_days_kwh:    hot_water_winter_kwh,
        hot_water_percent_of_total_kwh:   percent_hw,
        degreeday_adjustment_percent:     change_in_degree_days_percent,
        percent_change_due_to_adjustment: percent,
        total_heating_kwh:                total_kwh * (1.0 - percent_hw),
        total_kwh:                        total_kwh,
        total_adjusted_kwh:               adjusted_kwh,
        start_date:                       start_date,
        end_date:                         end_date
      }
      results.merge!(hw_analysis) unless hw_analysis.nil?
      results
    end
  end
end
