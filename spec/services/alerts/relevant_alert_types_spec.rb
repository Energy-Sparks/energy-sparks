require 'rails_helper'

describe Alerts::RelevantAlertTypes do
  let!(:no_fuel_alert_type)          { create(:alert_type, fuel_type: nil) }
  let!(:electricity_alert_type)      { create(:alert_type, fuel_type: :electricity) }
  let!(:gas_alert_type)              { create(:alert_type, fuel_type: :gas) }
  let!(:storage_heater_alert_type)   { create(:alert_type, fuel_type: :storage_heater) }
  let!(:solar_pv_alert_type)         { create(:alert_type, fuel_type: :solar_pv) }

  let(:school)                      { create(:school) }

  it 'returns electricity and gas ones' do
    fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: true)
    school.configuration.update(fuel_configuration: fuel_configuration)

    service = Alerts::RelevantAlertTypes.new(school)
    expect(service.list).to include(no_fuel_alert_type, electricity_alert_type, gas_alert_type)
    expect(service.list).to_not include(storage_heater_alert_type, solar_pv_alert_type)
  end

  it 'returns storage heater and electricity' do
    fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true, has_storage_heaters: true)
    school.configuration.update(fuel_configuration: fuel_configuration)

    service = Alerts::RelevantAlertTypes.new(school)
    expect(service.list).to include(no_fuel_alert_type, electricity_alert_type, storage_heater_alert_type)
    expect(service.list).to_not include(gas_alert_type, solar_pv_alert_type)
  end

  it 'returns storage heater and electricity and solar pv' do
    fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true, has_storage_heaters: true, has_solar_pv: true)
    school.configuration.update(fuel_configuration: fuel_configuration)

    service = Alerts::RelevantAlertTypes.new(school)
    expect(service.list).to include(no_fuel_alert_type, electricity_alert_type, storage_heater_alert_type, solar_pv_alert_type)
    expect(service.list).to_not include(gas_alert_type)
  end

  it 'returns gas and no fuel only' do
    fuel_configuration = Schools::FuelConfiguration.new(has_gas: true)
    school.configuration.update(fuel_configuration: fuel_configuration)

    service = Alerts::RelevantAlertTypes.new(school)
    expect(service.list).to include(gas_alert_type, no_fuel_alert_type)
    expect(service.list).to_not include(electricity_alert_type, storage_heater_alert_type, solar_pv_alert_type)
  end
end
