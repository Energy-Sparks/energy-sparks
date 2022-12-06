require 'rails_helper'

describe Targets::GenerateProgressService do

  let!(:school)                   { create(:school) }
  let!(:aggregated_school)        { double('meter-collection') }
  let!(:school_target)            { create(:school_target, school: school) }

  let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types)  { ["electricity"] }

  let!(:school_config)            { create(:configuration, school: school, fuel_configuration: fuel_electricity, school_target_fuel_types: school_target_fuel_types) }

  let!(:service)                  { Targets::GenerateProgressService.new(school, aggregated_school) }

  let(:months)                    { [Date.today.last_month.beginning_of_month, Date.today.beginning_of_month] }
  let(:fuel_type)                 { :electricity }
  let(:monthly_targets_kwh)       { [10,10] }
  let(:monthly_usage_kwh)         { [10,5] }
  let(:monthly_performance)       { [-0.25,0.35] }
  let(:cumulative_targets_kwh)    { [10,20] }
  let(:cumulative_usage_kwh)      { [10,15] }
  let(:cumulative_performance)    { [-0.99,0.99] }
  let(:partial_months)            { [false, true] }
  let(:percentage_synthetic)      { [0, 0]}

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
        partial_months: partial_months,
        percentage_synthetic: percentage_synthetic
    )
  end

  before(:each) do
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregated_school)
  end

  context '#cumulative_progress' do
    context 'and there is an error in the progress report generation' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end

      it 'returns nil' do
        expect(service.cumulative_progress(:electricity)).to be_nil
      end
    end

    context 'and there is an error in the pre-conditions' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_raise(StandardError.new('test requested'))
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
          allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
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
      allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'returns the right value' do
      expect(service.current_monthly_target(:electricity)).to eql 20
    end
  end

  context '#current_monthly_usage' do
    before(:each) do
      allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'returns the right value' do
      expect(service.current_monthly_usage(:electricity)).to eql 15
    end
  end

  context '#generate!' do
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

      it 'saved the progress report' do
        expect( target.saved_progress_report_for(:electricity).to_json ).to eq(progress.to_json)
      end

      it 'records when last run' do
        expect( target.report_last_generated ).to_not be_nil
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
    end

    context 'and not enough data' do
      let(:school_target_fuel_types)  { [] }

      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
      end
      it 'generates' do
        expect( service.generate! ).to eq school_target
      end
    end
  end

end
