require 'rails_helper'

RSpec.describe Targets::ProgressService do

  let!(:school)             { create(:school) }
  let!(:aggregated_school)  { double('meter-collection') }
  let(:target)              { create(:school_target, school: school) }
  let(:fuel_electricity)    { Schools::FuelConfiguration.new(has_electricity: true) }
  let!(:service)            { Targets::ProgressService.new(school, aggregated_school) }
  let!(:school_config)      { create(:configuration, school: school, fuel_configuration: fuel_electricity) }

  let(:months)                    { ['jan', 'feb'] }
  let(:fuel_type)                 { :electricity }
  let(:monthly_targets_kwh)       { [1,2] }
  let(:monthly_usage_kwh)         { [1,2] }
  let(:monthly_performance)       { [-0.25,0.35] }
  let(:cumulative_targets_kwh)    { [1,2] }
  let(:cumulative_usage_kwh)      { [1,2] }
  let(:cumulative_performance)    { [-0.99,0.99] }
  let(:partial_months)            { ['feb'] }

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

  context 'when calculating progress' do
    context 'and there is an error' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end

      it 'returns nil' do
        expect(service.electricity_progress).to be_nil
      end
    end

    context 'for electricity' do
      context 'and there is no fuel type' do
        let(:fuel_electricity)    { Schools::FuelConfiguration.new(has_electricity: false) }
        it 'returns nil' do
          expect(service.electricity_progress).to be_nil
        end
      end

      context 'and there is electricity' do

        before(:each) do
          allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        end

        it 'returns the value' do
          expect(service.electricity_progress).to be 0.99
        end
      end
    end
  end

  context 'when calculating the management dashboard' do
    context 'and there is no ManagementDashboardTable' do
      it 'returns nil' do
        expect(service.setup_management_table).to be_nil
      end
    end

    context 'and there is a ManagementDashboardTable' do
      let!(:content_generation_run) { create(:content_generation_run, school: school)}

      let(:summary) {
        [
          ["", "Annual Use (kWh)", "Annual CO2 (kg)", "Annual Cost", "Change from last year", "Change in last 4 school weeks", "Potential savings"],
          ["Electricity", "730,000", "140,000", "£110,000", "+12%", "-8.5%", "£83,000"],
          ["Gas", "not enough data", "not enough data", "not enough data", "not enough data", "-50%", "not enough data"]
        ]
      }
      let(:table_data)  { { 'summary_table' => summary } }

      let!(:alert)     { create(:alert, table_data: table_data ) }
      let!(:management_dashboard_table) { create(:management_dashboard_table, content_generation_run: content_generation_run, alert: alert) }

      context 'but the feature flag is off' do
        before(:each) do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
        end
        it 'does not include the progress' do
          expect(service.setup_management_table).to eql summary
        end
      end

      context 'but the feature flag is on' do
        before(:each) do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
          allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        end

        it 'includes the progress' do
          table = service.setup_management_table
          table.each do |row|
            expect(row.size).to eql 8
          end
          expect(table[0]).to include("Target progress")
          expect(table[1]).to include("+99%")
        end
      end
    end
  end

end
