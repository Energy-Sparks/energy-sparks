# frozen_string_literal: true

class TargetsService
  class AnnualKwhEstimate
    attr_reader :meter, :school

    def initialize(meter)
      @school = meter.meter_collection
      @meter = meter
    end

    def calculate_apportioned_annual_estimate
      crude_annual_kwh = calculate_crude_annual_kwh
      return crude_annual_kwh[:kwh] if crude_annual_kwh[:percent] >= 0.98

      if meter.fuel_type == :electricity
        calculate_apportioned_annual_electricity_estimate(crude_annual_kwh)
      else
        calculate_apportioned_annual_heating_estimate(crude_annual_kwh)
      end
    end

    private

    def calculate_crude_annual_kwh
      ed = meter.amr_data.end_date
      sd = [meter.amr_data.start_date, ed - 364].max

      {
        kwh: meter.amr_data.kwh_date_range(sd, ed),
        percent: (ed - sd + 1) / 365.0,
        start_date: sd,
        end_date: ed
      }
    end

    def calculate_apportioned_annual_heating_estimate(annual_kwh_estimate)
      # degree day base set to 20.0C in an attempt to simulate hot water consumption over the summer
      annnual_degreedays = meter.meter_collection.temperatures.degree_days_in_date_range(
        annual_kwh_estimate[:end_date] - 365, annual_kwh_estimate[:end_date], 20.0
      )
      meter_degreedays = meter.meter_collection.temperatures.degree_days_in_date_range(annual_kwh_estimate[:start_date],
                                                                                       annual_kwh_estimate[:end_date], 20.0)
      annual_kwh_estimate[:kwh] * annnual_degreedays / meter_degreedays
    end

    # uses degree days and solar irradiance to adjust but include baseload factor
    # solar irradiance too difficult?
    def calculate_apportioned_annual_electricity_estimate(annual_kwh_estimate)
      school = meter.meter_collection
      ed = annual_kwh_estimate[:end_date]
      sd = ed - 365

      baseload_kw =
        Baseload::BaseloadAnalysis.new(meter).average_baseload_kw(annual_kwh_estimate[:start_date], ed)

      annnual_degreedays = school.temperatures.degree_days_in_date_range(sd, ed, 20.0)
      meter_degreedays = school.temperatures.degree_days_in_date_range(annual_kwh_estimate[:start_date], ed, 20.0)

      model = electrical_solar_degreeday_model(annual_kwh_estimate[:start_date], ed)

      estimate_annual_electrical_kwh(model, baseload_kw)
    end

    def in_third_lockdown?(date)
      start_date, end_date = Covid3rdLockdownElectricityCorrection.determine_3rd_lockdown_dates(school.country)
      date.between?(start_date, end_date)
    end

    def estimate_annual_electrical_kwh(model, baseload_kw)
      amr_data = meter.amr_data
      solar_ir = school.solar_irradiation
      temperatures = school.temperatures
      open_time = school.open_time..school.close_time
      open_times_x48 = DateTimeHelper.weighted_x48_vector_multiple_ranges([open_time])

      ((amr_data.end_date - 365)..amr_data.end_date).sum do |date|
        if amr_data.date_exists?(date) && !in_third_lockdown?(date)
          amr_data.one_day_kwh(date)
        else
          dd = school.temperatures.degree_days(date)
          ir_x48 = school.solar_irradiation.one_days_data_x48(date)

          model[school.holidays.day_type(date)].interpolate(dd, ir_x48)
        end
      end
    end

    def electrical_solar_degreeday_model(sd, ed)
      model = BivariateSolarTemperatureModel.new(meter.amr_data, school.temperatures, school.solar_irradiation,
                                                 school.holidays, open_time: school.open_time, close_time: school.close_time)
      third_lockdown = Covid3rdLockdownElectricityCorrection.determine_3rd_lockdown_dates(school.country)
      {
        schoolday: model.fit(sd..ed, exclude_dates_or_ranges: third_lockdown, day_type: :schoolday),
        weekend: model.fit(sd..ed, exclude_dates_or_ranges: third_lockdown, day_type: :weekend),
        holiday: model.fit(sd..ed, exclude_dates_or_ranges: third_lockdown, day_type: :holiday)
      }
    end
  end
end
