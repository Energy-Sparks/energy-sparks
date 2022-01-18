require 'rails_helper'

describe Targets::GenerateProgressService do

  let!(:school)                   { create(:school) }
  let!(:aggregated_school)        { double('meter-collection') }
  let!(:school_target)            { create(:school_target, school: school) }

  let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types)  { ["electricity"] }

  let!(:school_config)            { create(:configuration, school: school, fuel_configuration: fuel_electricity, school_target_fuel_types: school_target_fuel_types) }

  let!(:service)                  { Targets::GenerateProgressService.new(school, aggregated_school) }

  let(:months)                    { [Date.today.last_month.strftime("%b"), Date.today.strftime("%b")] }
  let(:fuel_type)                 { :electricity }
  let(:monthly_targets_kwh)       { [10,10] }
  let(:monthly_usage_kwh)         { [10,5] }
  let(:monthly_performance)       { [-0.25,0.35] }
  let(:cumulative_targets_kwh)    { [10,20] }
  let(:cumulative_usage_kwh)      { [10,15] }
  let(:cumulative_performance)    { [-0.99,0.99] }
  let(:partial_months)            { [Date.today.strftime("%b")] }

  let(:progress) do
    TargetsProgress.new(
        fuel_type: fuel_type,
        months: months,
        monthly_targets_kwh: monthly_targets_kwh,
        monthly_usage_kwh: monthly_usage_kwh,
        monthly_performance: monthly_performance,
        cumulative_targets_kwh: cumulative_targets_kwh,
        cumulative_usage_kwh: cumulative_usage_kwh,
        cumulative_performance: cumulative_performance,
        cumulative_performance_versus_synthetic_last_year: cumulative_performance,
        monthly_performance_versus_synthetic_last_year: monthly_performance,
        partial_months: partial_months
    )
  end

  before(:each) do
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
  end

  context '#cumulative_progress' do
    context 'and there is an error' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end

      it 'returns nil' do
        expect(service.cumulative_progress(:electricity)).to be_nil
      end
    end

    context 'for a fuel type' do
      context 'and its not present' do
        let(:fuel_electricity)    { Schools::FuelConfiguration.new(has_electricity: false) }
        it 'returns nil' do
          expect(service.cumulative_progress(:electricity)).to be_nil
        end
      end

      context 'and it is present' do

        before(:each) do
          allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        end

        it 'returns the value' do
          expect(service.cumulative_progress(:electricity)).to be 0.99
        end
      end
    end
  end

  context '#current_monthly_target' do
    before(:each) do
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'returns the right value' do
      expect(service.current_monthly_target(:electricity)).to eql 20
    end
  end

  context '#current_monthly_usage' do
    before(:each) do
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'returns the right value' do
      expect(service.current_monthly_usage(:electricity)).to eql 15
    end
  end

  context '#generate!' do
    context 'and school targets are active' do
      before(:each) do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      end

      it 'does nothing if school has no target' do
        SchoolTarget.all.destroy_all
        expect( service.generate! ).to be nil
      end

      context 'with only electricity fuel type' do

        before(:each) do
          allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
          allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
          allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
        end

        let(:target) { service.generate! }

        it 'updates the target' do
          expect( target ).to eql school_target
        end

        it 'includes only that fuel type' do
          expect( target.gas_progress ).to eq({})
          expect( target.storage_heaters_progress ).to eq({})
          expect( target.electricity_progress ).to_not eq({})
        end

        it 'reports the fuel progress' do
          expect( target.electricity_progress["progress"] ).to eql 0.99
          expect( target.electricity_progress["usage"] ).to eql 15
          expect( target.electricity_progress["target"] ).to eql 20
        end

        it 'does nothing if feature disabled' do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
          expect( service.generate! ).to be nil
          school.update!(enable_targets_feature: false)
          expect( service.generate! ).to be nil
        end
      end

      context 'and not enough data' do
        let(:school_target_fuel_types)  { [] }

        it 'does nothing' do
          expect( service.generate! ).to eq school_target
        end

      end

    end
  end

end
