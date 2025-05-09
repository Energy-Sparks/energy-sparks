class SyntheticMeter < Dashboard::Meter
  include Logging

  def initialize(meter_to_clone)
    super(
      meter_collection: meter_to_clone.meter_collection,
      amr_data: nil,
      type: meter_to_clone.meter_type,
      name: meter_to_clone.name,
      identifier: meter_to_clone.id,
      floor_area: meter_to_clone.floor_area,
      number_of_pupils: meter_to_clone.number_of_pupils,
      solar_pv_installation: meter_to_clone.solar_pv_setup,
      meter_attributes: meter_to_clone.meter_attributes
    )
  end

  def set_carbon_and_costs
    calculate_carbon_emissions_for_meter
    calculate_costs_for_meter
  end

  private

  def calculate_carbon_emissions_for_meter
    if fuel_type == :electricity ||
       fuel_type == :aggregated_electricity ||
        TargetMeter.storage_heater_fuel_type?(fuel_type)
      @amr_data.set_carbon_emissions(id, nil, @meter_collection.grid_carbon_intensity)
    else
      @amr_data.set_carbon_emissions(id, EnergyEquivalences::UK_GAS_CO2_KG_KWH, nil)
    end
  end

  def calculate_costs_for_meter
    logger.info "Creating economic & accounting costs for target #{mpan_mprn} fuel #{fuel_type} from #{amr_data.start_date} to #{amr_data.end_date}"
    set_tariffs
  end
end
