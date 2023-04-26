require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::OutOfHoursUsageBenchmarkGenerator, type: :service do

  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :electricity_out_of_hours, fuel_type: :electricity) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service)     { Schools::AdvicePageBenchmarks::OutOfHoursUsageBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  context '#benchmark_school' do
    let(:enough_data) { true }
    let(:usage) {
      CombinedUsageMetric.new(
        £: 12.0,
        kwh: 12.0,
        co2: 12.0,
        percent: 0.4
      )
    }
    before(:each) do
      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:usage_breakdown) do
        Usage::AnnualUsageCategoryBreakdown.new(
          holiday: usage,
          school_day_closed: usage,
          school_day_open: usage,
          weekend: usage,
          out_of_hours: usage,
          community: usage,
          fuel_type: :electricity
        )
      end
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:potential_savings) { usage }
    end

    context 'not enough data' do
      let(:enough_data) { false }
      it 'does not benchmark' do
        expect(service.benchmark_school).to be_nil
      end
    end

    context 'with a comparison' do
      it 'returns the comparison category' do
        expect(service.benchmark_school).to eq :exemplar_school
      end
    end

  end
end
