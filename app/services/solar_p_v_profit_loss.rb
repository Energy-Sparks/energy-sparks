# frozen_string_literal: true

class SolarPVProfitLoss
  def initialize(meter_collection)
    @meter_collection = meter_collection
  end

  def annual_electricity_including_onsite_solar_pv_consumption_kwh
    last_years_kwh(@meter_collection.aggregated_electricity_meters)[:kwh]
  end

  def annual_solar_pv_consumed_onsite_kwh
    last_years_kwh(sub_meter(:self_consume))[:kwh]
  end

  def annual_exported_solar_pv_kwh
    last_years_kwh(sub_meter(:export))[:kwh]
  end

  def annual_solar_pv_kwh
    # report using data from the generation meter, rather than adding up the other
    # figures. This aligns this class with what the charts and the change in
    # solar pv benchmark use
    # annual_solar_pv_consumed_onsite_kwh + annual_exported_solar_pv_kwh
    last_years_kwh(sub_meter(:generation))[:kwh]
  end

  def annual_saving_from_solar_pv_percent
    annual_solar_pv_consumed_onsite_kwh / annual_electricity_including_onsite_solar_pv_consumption_kwh
  end

  def annual_carbon_saving_percent
    annual_solar_pv_kwh / annual_electricity_including_onsite_solar_pv_consumption_kwh
  end

  def annual_consumed_from_national_grid_kwh
    annual_electricity_including_onsite_solar_pv_consumption_kwh - annual_solar_pv_consumed_onsite_kwh
  end

  def annual_co2_saving_kg
    last_years_kwh(sub_meter(:generation))[:co2]
  end

  private

  def last_years_kwh(meter)
    @last_years_kwh_cache ||= {}
    @last_years_kwh_cache[meter.name] ||= calculate_years_kwh(meter)
  end

  def calculate_years_kwh(meter)
    end_date = meter.amr_data.end_date
    start_date = [end_date - 365, meter.amr_data.start_date].max
    days = end_date - start_date + 1

    kwh = meter.amr_data.kwh_date_range(start_date, end_date, :kwh)
    co2 = meter.amr_data.kwh_date_range(start_date, end_date, :co2)

    {
      start_date: start_date,
      end_date: end_date,
      kwh: kwh.magnitude,
      days: days,
      co2: co2.magnitude,
      period_description: FormatUnit.format(:years, days / 365.0, :text)
    }
  end

  def period_description(days)
    return unless days >= 364 - 15

    'last year'
  end

  def sub_meter(meter_type)
    @meter_collection.aggregated_electricity_meters.sub_meters[meter_type]
  end
end
