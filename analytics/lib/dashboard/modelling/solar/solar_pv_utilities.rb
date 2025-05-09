# a series of utilities to support solar panels - there are also
# similar classes elsewhere in the code base
#
class SolarPVUtilities
  def initialize(meter_collection)
    @meter_collection = meter_collection
  end

  def full_years_solar_installation?
    Date.today - first_non_zero_pv_generation_date + 1 >= 365
  end

  def first_non_zero_pv_generation_date
    @first_non_zero_pv_generation_date ||= calc_first_non_zero_pv_generation_date
  end

  def last_generation_meter_date
    aggregate_meter.sub_meters[:generation].amr_data.end_date
  end

  def calc_first_non_zero_pv_generation_date
    meter_data = aggregate_meter.sub_meters[:generation].amr_data
    (meter_data.start_date..meter_data.end_date).each do |date|
      return date if meter_data[date].one_day_kwh > 0.0
    end
    nil
  end

  def install_month_year_text(format = '%B %Y')
    first_non_zero_pv_generation_date.strftime(format)
  end

  private

  def aggregate_meter
    @meter_collection.aggregated_electricity_meters
  end
end