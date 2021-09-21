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

      let(:aggregate_electricity_meter)   { double('aggregate-electricity-meter') }
      let(:aggregate_gas_meter)           { double('aggregate-gas-meter') }

      let(:amr_data)                      { double('amr-data') }

      before(:each) do
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
        allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate?).and_return(false)

        allow(aggregated_school).to receive(:aggregate_meter).with(:electricity).and_return(aggregate_electricity_meter)
        allow(aggregated_school).to receive(:aggregate_meter).with(:gas).and_return(aggregate_gas_meter)
        allow(aggregated_school).to receive(:aggregate_meter).with(:storage_heater).and_return(nil)

        allow(aggregate_electricity_meter).to receive(:amr_data).and_return(amr_data)
        allow(aggregate_gas_meter).to receive(:amr_data).and_return(amr_data)

        allow(amr_data).to receive(:end_date).and_return(Time.zone.today.last_month)
      end

      it 'should default to the previous month' do
        expect(target.start_date).to eql last_month
      end

    end
  end

  describe '#enough_data?' do
    before(:each) do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
    end

    context 'and there isnt enough data' do
      before(:each) do
        allow_any_instance_of(::TargetsService).to receive(:enough_data_to_set_target?).and_return(false)
      end
      it 'returns false' do
        expect(service.enough_data?).to be false
      end
    end

    context 'and there is enough data' do
      before(:each) do
        allow_any_instance_of(::TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
      end

      it 'returns true' do
        expect(service.enough_data?).to be true
      end
    end
  end
end
