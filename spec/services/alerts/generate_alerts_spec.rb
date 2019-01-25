# require 'rails_helper'

# describe Alerts::GenerateAlerts do

#   let!(:no_fuel_alert_type) { create(:alert_type, fuel_type: nil, frequency: :weekly) }
#   let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
#   let!(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :weekly) }
#   let(:school) { create(:school) }
#   let(:gas_date) { Date.parse('2019-01-01') }
#   let(:electricity_date) { Date.parse('2019-02-01') }
#   let(:alert_framework_adapter) { double(Alerts::FrameworkAdapter) }
#   let(:alert_framework_adapter_instance) { instance_double('alert_framework_adapter_instance') }
#   let(:alert_framework_adapter_instance_gas) { instance_double('alert_framework_adapter_instance_gas') }
#   let(:alert_framework_adapter_instance_electricity) { instance_double('alert_framework_adapter_instance_electricity') }

#   context 'school with no meters' do
#     it 'should run no fuel alert' do
#       no_fuel_output = ['No fuel run']
#       expect(alert_framework_adapter).to receive(:new).with(no_fuel_alert_type, school, Time.zone.today).and_return(alert_framework_adapter_instance)
#       expect(alert_framework_adapter_instance).to receive(:analyse).and_return(no_fuel_output)
#       output = Alerts::GenerateAlerts.new(school, gas_date, electricity_date, alert_framework_adapter).weekly
#       expect(output).to eq no_fuel_output
#     end
#   end

#   context 'school with gas meters' do
#     it 'should run no fuel alert and gas' do
#       no_fuel_output = ['No fuel run']
#       gas_fuel_output = ['Gas fuel output']
#       create(:gas_meter_with_validated_reading, school: school)
#       expect(alert_framework_adapter).to receive(:new).with(no_fuel_alert_type, school, Time.zone.today).ordered.and_return(alert_framework_adapter_instance)
#       expect(alert_framework_adapter).to receive(:new).with(gas_fuel_alert_type, school, gas_date).ordered.and_return(alert_framework_adapter_instance_gas)
#       expect(alert_framework_adapter_instance).to receive(:analyse).and_return(no_fuel_output)
#       expect(alert_framework_adapter_instance_gas).to receive(:analyse).and_return(gas_fuel_output)

#       output = Alerts::GenerateAlerts.new(school, gas_date, electricity_date, alert_framework_adapter).weekly
#       expect(output).to eq [no_fuel_output, gas_fuel_output].flatten
#     end
#   end

#   context 'school with electrictity meters' do
#     it 'should run no fuel alert and electrictity' do
#       no_fuel_output = ['No fuel run']
#       electricity_fuel_output = ['electricity fuel output']
#       create(:electricity_meter_with_validated_reading, school: school)
#       expect(alert_framework_adapter).to receive(:new).with(no_fuel_alert_type, school, Time.zone.today).ordered.and_return(alert_framework_adapter_instance)
#       expect(alert_framework_adapter).to receive(:new).with(electricity_fuel_alert_type, school, electricity_date).ordered.and_return(alert_framework_adapter_instance_electricity)
#       expect(alert_framework_adapter_instance).to receive(:analyse).and_return(no_fuel_output)
#       expect(alert_framework_adapter_instance_electricity).to receive(:analyse).and_return(electricity_fuel_output)

#       output = Alerts::GenerateAlerts.new(school, gas_date, electricity_date, alert_framework_adapter).weekly
#       expect(output).to eq [no_fuel_output, electricity_fuel_output].flatten
#     end
#   end

#   context 'school with both meters' do
#     it 'should run no fuel alert and electrictity' do
#       no_fuel_output = ['No fuel run']
#       electricity_fuel_output = ['electricity fuel output']
#       gas_fuel_output = ['Gas fuel output']
#       create(:electricity_meter_with_validated_reading, school: school)
#       create(:gas_meter_with_validated_reading, school: school)

#       expect(alert_framework_adapter).to receive(:new).with(no_fuel_alert_type, school, Time.zone.today).ordered.and_return(alert_framework_adapter_instance)
#       expect(alert_framework_adapter).to receive(:new).with(electricity_fuel_alert_type, school, electricity_date).ordered.and_return(alert_framework_adapter_instance_electricity)
#       expect(alert_framework_adapter).to receive(:new).with(gas_fuel_alert_type, school, gas_date).ordered.and_return(alert_framework_adapter_instance_gas)

#       expect(alert_framework_adapter_instance).to receive(:analyse).and_return(no_fuel_output)
#       expect(alert_framework_adapter_instance_electricity).to receive(:analyse).and_return(electricity_fuel_output)
#       expect(alert_framework_adapter_instance_gas).to receive(:analyse).and_return(gas_fuel_output)

#       output = Alerts::GenerateAlerts.new(school, gas_date, electricity_date, alert_framework_adapter).weekly
#       expect(output).to eq [no_fuel_output, electricity_fuel_output, gas_fuel_output].flatten
#     end
#   end
# end
