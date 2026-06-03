require 'rails_helper'

RSpec.describe Targets::SchoolTargetService do
  let!(:school)             { create(:school) }
  let!(:aggregated_school)  { double('meter-collection') }

  let!(:service)            { Targets::SchoolTargetService.new(school) }

  let(:fuel_configuration) do
    Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true)
  end

  before do
    school.configuration.update!(fuel_configuration: fuel_configuration)
    allow_any_instance_of(Targets::TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)
  end

  describe '#build_target' do
    context 'a new target' do
      let(:target) { service.build_target }

      it 'defaults to this month' do
        expect(target.start_date).to eql Time.zone.today.beginning_of_month
      end

      it 'defaults to 12 months from now' do
        expect((target.target_date - target.start_date).to_i).to be_between(365, 366)
      end

      it 'has default values' do
        expect(target.electricity).to eql Targets::SchoolTargetService::DEFAULT_ELECTRICITY_TARGET
        expect(target.gas).to eql Targets::SchoolTargetService::DEFAULT_GAS_TARGET
        expect(target.storage_heaters).to eql Targets::SchoolTargetService::DEFAULT_STORAGE_HEATER_TARGET
      end

      context 'and school has limited fuel types' do
        let(:fuel_configuration) do
          Schools::FuelConfiguration.new(
            has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true)
        end

        before do
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
      let(:start_date)      { Time.zone.today.last_year}
      let(:target_date)     { start_date.next_year }

      let!(:old_target) { create(:school_target, school: school, start_date: start_date, target_date: target_date) }
      let(:target) { service.build_target }

      it 'defaults to end of previous target' do
        expect(target.start_date).to eq old_target.target_date
      end

      it 'defaults to 12 months from now' do
        expect((target.target_date - target.start_date).to_i).to be_between(365, 366)
      end

      it 'inherits targets' do
        expect(target.electricity).to eql old_target.electricity
        expect(target.gas).to eql old_target.gas
        expect(target.storage_heaters).to eql old_target.storage_heaters
      end
    end

    context 'when meters are running slightly behind' do
      let(:last_month) { Time.zone.today.last_month.beginning_of_month }
      let(:this_month) { Time.zone.today.beginning_of_month }

      let(:target) { service.build_target }

      before do
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
        allow_any_instance_of(Targets::TargetsService).to receive(:annual_kwh_estimate?).and_return(false)
        allow_any_instance_of(Targets::TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(Targets::TargetsService).to receive(:meter_present?).and_return(true)
        allow_any_instance_of(Targets::TargetsService).to receive(:default_target_start_date).and_return(last_month)
      end

      it 'defaults to the previous month' do
        expect(target.start_date).to eql last_month
      end
    end
  end

  describe '#enough_data?' do
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
