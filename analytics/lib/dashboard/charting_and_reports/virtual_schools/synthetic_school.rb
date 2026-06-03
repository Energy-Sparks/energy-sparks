class SyntheticSchool < MeterCollection
  def initialize(meter_collection)
    super(meter_collection.school,
          holidays:                 meter_collection.holidays,
          temperatures:             meter_collection.temperatures,
          solar_irradiation:        meter_collection.solar_irradiation,
          solar_pv:                 meter_collection.solar_pv,
          grid_carbon_intensity:    meter_collection.grid_carbon_intensity,
          pseudo_meter_attributes:  meter_collection.pseudo_meter_attributes_private)

    @original_school = meter_collection
  end
end
