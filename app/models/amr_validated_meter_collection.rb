# From analytics code - tweaked
require 'dashboard'

class AmrValidatedMeterCollection < AmrMeterCollection
  NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS = 366

  def add_amr_data(dashboard_meter, active_record_meter)
    amr_data = AMRData.new(dashboard_meter.meter_type)

    validated_reading_array = AmrValidatedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).pluck(:reading_date, :status, :substitute_date, :upload_datetime, :kwh_data_x48)
    validated_reading_array.each do |reading|
      amr_data.add(reading[0], OneDayAMRReading.new(active_record_meter.id, reading[0], reading[1], reading[2], reading[3], reading[4].map(&:to_f)))
    end

    dashboard_meter.amr_data = amr_data
    dashboard_meter
  end

  # Override so we only set up meters with enough data for analytics
  def set_up_meters(active_record_school)
    @heat_meters = active_record_school.meters_with_enough_validated_readings_for_analysis(:gas, NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS).map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(self, nil, active_record_meter.meter_type.to_sym, active_record_meter.mpan_mprn, active_record_meter.name, nil, nil, nil, nil, active_record_meter.id)
      add_amr_data(dashboard_meter, active_record_meter)
    end

    @electricity_meters = active_record_school.meters_with_enough_validated_readings_for_analysis(:electricity, NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS).map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(self, nil, active_record_meter.meter_type.to_sym, active_record_meter.mpan_mprn, active_record_meter.name, nil, nil, nil, nil, active_record_meter.id)
      add_amr_data(dashboard_meter, active_record_meter)
    end
  end

  def analysis_date(fuel_type)
    fuel_type = fuel_type.to_sym
    if fuel_type == :gas
      aggregated_heat_meters.amr_data.keys.last
    elsif fuel_type == :electricity
      aggregated_electricity_meters.amr_data.keys.last
    else
      Time.zone.today
    end
  end
end
