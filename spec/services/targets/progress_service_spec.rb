require 'rails_helper'

RSpec.describe Targets::ProgressService do

  let!(:school)                   { create(:school) }
  let!(:electricity_progress)     { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
  let!(:school_target)            { create(:school_target, school: school, electricity_progress: electricity_progress) }

  let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types)  { ["electricity"] }

  let!(:school_config)            { create(:configuration, school: school, fuel_configuration: fuel_electricity, school_target_fuel_types: school_target_fuel_types) }

  let!(:service)                  { Targets::ProgressService.new(school) }

  context '#progress_summary' do
    context 'and school targets are active' do
      before(:each) do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      end

      it 'returns nil if school has no target' do
        SchoolTarget.all.destroy_all
        expect( service.progress_summary ).to be nil
      end

      context 'with only electricity fuel type' do
        let(:progress_summary) { service.progress_summary }

        it 'includes school target in summary' do
          expect( progress_summary.school_target ).to eql school_target
        end

        it 'includes only that fuel type' do
          expect( progress_summary.gas_progress ).to be nil
          expect( progress_summary.storage_heater_progress ).to be nil
          expect( progress_summary.electricity_progress ).to_not be nil
        end

        it 'reports the fuel progress' do
          expect( progress_summary.electricity_progress.progress ).to eql 0.99
          expect( progress_summary.electricity_progress.usage ).to eql 15
          expect( progress_summary.electricity_progress.target ).to eql 20
        end

        it 'returns nil if feature disabled' do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
          expect( service.progress_summary ).to be nil
          school.update!(enable_targets_feature: false)
          expect( service.progress_summary ).to be nil
        end
      end
    end
  end
end
