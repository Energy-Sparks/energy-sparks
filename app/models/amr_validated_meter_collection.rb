# From analytics code - tweaked
require 'dashboard'

class AmrValidatedMeterCollection < AmrMeterCollection
  NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS = 366

  def add_amr_data(dashboard_meter, active_record_meter)
    amr_data = AMRData.new(dashboard_meter.meter_type)

    AmrValidatedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).each do |reading|
      amr_data.add(reading.reading_date, OneDayAMRReading.new(active_record_meter.id, reading.reading_date, reading.status, reading.substitute_date, reading.upload_datetime, reading.kwh_data_x48.map(&:to_f)))
    end

    dashboard_meter.amr_data = amr_data
    dashboard_meter
  end

  # Override so we only set up meters with enough data for analytics
  def set_up_meters(active_record_school)
    @heat_meters = active_record_school.meters_with_enough_validated_readings_for_analysis(:gas, NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS).map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(@school, nil, active_record_meter.meter_type.to_sym, active_record_meter.mpan_mprn, active_record_meter.name, nil, nil, nil, nil, active_record_meter.id)
      add_amr_data(dashboard_meter, active_record_meter)
    end

    @electricity_meters = active_record_school.meters_with_enough_validated_readings_for_analysis(:electricity, NUMBER_OF_READINGS_REQUIRED_FOR_ANALYTICS).map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(@school, nil, active_record_meter.meter_type.to_sym, active_record_meter.mpan_mprn, active_record_meter.name, nil, nil, nil, nil, active_record_meter.id)
      add_amr_data(dashboard_meter, active_record_meter)
    end
  end
end
