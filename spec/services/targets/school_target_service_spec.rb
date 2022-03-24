require 'rails_helper'

RSpec.describe Targets::SchoolTargetService do

  let!(:school)             { create(:school) }
  let!(:aggregated_school)  { double('meter-collection') }

  let!(:service)            { Targets::SchoolTargetService.new(school) }

  let(:fuel_configuration)   { Schools::FuelConfiguration.new(
    has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true) }

  before(:each) do
    school.configuration.update!(fuel_configuration: fuel_configuration)
    allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)
  end

  describe '#build_target' do
    context 'a new target' do
      let(:target) { service.build_target }

      it 'should default to this month' do
        expect(target.start_date).to eql Time.zone.today.beginning_of_month
      end

      it 'should default to 12 months from now' do
        expect((target.target_date - target.start_date).to_i).to eql 365
      end

      it 'should have default values' do
        expect(target.electricity).to eql Targets::SchoolTargetService::DEFAULT_ELECTRICITY_TARGET
        expect(target.gas).to eql Targets::SchoolTargetService::DEFAULT_GAS_TARGET
        expect(target.storage_heaters).to eql Targets::SchoolTargetService::DEFAULT_STORAGE_HEATER_TARGET
      end

      context 'and school has limited fuel types' do
        let(:fuel_configuration)   { Schools::FuelConfiguration.new(
          has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true) }

        before(:each) do
          school.configuration.update!(fuel_configuration: fuel_configuration)
        end

        it 'only sets defaults for those' do
          expect(target.electricity).to eql Targets::SchoolTargetService::DEFAULT_ELECTRICITY_TARGET
          expect(target.gas).to be nil
          expect(target.storage_heaters).to be nil
        end

      end
    end

    context 'an updated target' do
      let!(:old_target)  { create(:school_target, school: school) }
      let(:target) { service.build_target }

      it 'should default to this month' do
        expect(target.start_date).to eql Time.zone.today.beginning_of_month
      end

      it 'should default to 12 months from now' do
        expect((target.target_date - target.start_date).to_i).to eql 365
      end

      it 'should inherit targets' do
        expect(target.electricity).to eql old_target.electricity
        expect(target.gas).to eql old_target.gas
        expect(target.storage_heaters).to eql old_target.storage_heaters
      end
    end

    context 'when meters are running slightly behind' do
      let(:last_month) { Time.zone.today.last_month.beginning_of_month }
      let(:this_month) { Time.zone.today.beginning_of_month }

      let(:target) { service.build_target }

      before(:each) do
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
        allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate?).and_return(false)
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:meter_present?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:default_target_start_date).and_return(last_month)
      end

      it 'should default to the previous month' do
        expect(target.start_date).to eql last_month
      end

    end
  end

  describe '#enough_data? v2' do
    before(:each) do
      expect(EnergySparks::FeatureFlags).to receive(:active?).at_least(:once).with(:school_targets_v2).and_return(true)
    end

    context 'and there isnt enough data' do
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
    end

    context 'and there is enough data' do
      before(:each) do
        school.configuration.update!(school_target_fuel_types: ["electricity", "gas", "storage_heater"])
      end
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
      it 'checks for presence of fuel types' do
        expect(service.enough_data_for_electricity?).to be true
        expect(service.enough_data_for_gas?).to be true
        expect(service.enough_data_for_storage_heater?).to be true

        school.configuration.update(fuel_configuration: Schools::FuelConfiguration.new(
          has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true))
        expect(service.enough_data_for_electricity?).to be true
        expect(service.enough_data_for_gas?).to be false
        expect(service.enough_data_for_storage_heater?).to be false
      end
    end
  end

  describe '#enough_data?' do

    before(:each) do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
    end

    context 'and there isnt enough data' do
      it 'returns false' do
        expect(service.enough_data?).to be false
      end
    end

    context 'and there is enough data' do
      before(:each) do
        school.configuration.update!(school_target_fuel_types: ["electricity", "gas", "storage_heater"])
      end
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
      it 'checks the individual fuel types' do
        expect(service.enough_data_for_electricity?).to be true
        expect(service.enough_data_for_gas?).to be true
        expect(service.enough_data_for_storage_heater?).to be true
      end
      it 'handles missing fuel types' do
        school.configuration.update!(school_target_fuel_types: ["electricity"])
        expect(service.enough_data_for_electricity?).to be true
        expect(service.enough_data_for_gas?).to be false
        expect(service.enough_data_for_storage_heater?).to be false
      end
    end
  end
end
