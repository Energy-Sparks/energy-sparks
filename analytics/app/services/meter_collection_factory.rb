# frozen_string_literal: true

class MeterCollectionFactory
  def self.build(data)
    new(**data[:schedule_data]).build(**data.slice(:school_data, :amr_data, :pseudo_meter_attributes))
  end

  def initialize(temperatures:, solar_pv:, grid_carbon_intensity:, holidays:, solar_irradiation: nil)
    @temperatures = temperatures
    @solar_pv = solar_pv
    @solar_irradiation = solar_irradiation
    @grid_carbon_intensity = grid_carbon_intensity
    @holidays = holidays
  end

  def build(school_data:, amr_data: { electricity_meters: [], heat_meters: [] }, pseudo_meter_attributes: {}, meter_attributes_overrides: {})
    meter_collection = MeterCollection.new(Dashboard::School.new(school_data),
                                           temperatures: @temperatures,
                                           solar_pv: @solar_pv,
                                           solar_irradiation: @solar_irradiation,
                                           grid_carbon_intensity: @grid_carbon_intensity,
                                           holidays: @holidays,
                                           pseudo_meter_attributes: pseudo_meter_attributes)
    add_meters_and_amr_data(meter_collection, amr_data, meter_attributes_overrides)
    meter_collection
  end

  private

  def add_meters_and_amr_data(meter_collection, meter_data, meter_attributes_overrides)
    meter_data[:heat_meters].map do |meter|
      dashboard_meter = process_meters(meter_collection, meter, meter_attributes_overrides)
      meter_collection.add_heat_meter(dashboard_meter)
    end

    meter_data[:electricity_meters].map do |meter|
      dashboard_meter = process_meters(meter_collection, meter, meter_attributes_overrides)
      meter_collection.add_electricity_meter(dashboard_meter)
    end

    meter_collection
  end

  def process_meters(meter_collection, meter_data, meter_attributes_overrides)
    parent_meter = build_meter(meter_collection, meter_data, meter_attributes_overrides)
    meter_data.fetch(:sub_meters) { [] }.each do |sub_meter_data|
      parent_meter.sub_meters.push build_meter(meter_collection, sub_meter_data)
    end
    parent_meter
  end

  def build_meter(meter_collection, meter_data, meter_attributes_overrides)
    mpxn = meter_data[:identifier]
    attributes = meter_data[:attributes]
    attributes.merge!(meter_attributes_overrides[mpxn]) if meter_attributes_overrides.key?(mpxn)
    amr_data = AMRData.new(meter_data[:type])
    meter_data[:readings].each do |reading|
      add_reading(meter_data[:identifier], amr_data, reading)
    end
    Dashboard::Meter.new(
      meter_collection: meter_collection,
      amr_data: amr_data,
      type: meter_data[:type],
      identifier: mpxn,
      name: meter_data[:name],
      external_meter_id: meter_data[:external_meter_id],
      dcc_meter: meter_data[:dcc_meter],
      meter_attributes: attributes
    )
  end

  def add_reading(meter_id, amr_data, reading)
    if reading.is_a?(OneDayAMRReading)
      amr_data.add(reading.date, reading)
    else
      amr_data.add(reading[:reading_date], OneDayAMRReading.new(meter_id, reading[:reading_date], reading[:type], reading[:substitute_date], reading[:upload_datetime], reading[:kwh_data_x48]))
    end
  end
end
