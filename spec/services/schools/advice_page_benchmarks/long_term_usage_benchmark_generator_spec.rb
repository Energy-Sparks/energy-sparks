require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::LongTermUsageBenchmarkGenerator, type: :service do

  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :electricity_long_term, fuel_type: :electricity) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service)     { Schools::AdvicePageBenchmarks::LongTermUsageBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  context '#benchmark_school' do
    let(:enough_data) { true }
    let(:comparison) {
      Schools::Comparison.new(
        school_value: 42000.0,
        benchmark_value: 45000.0,
        exemplar_value: 30000.0,
        unit: :kw
      )
    }
    before(:each) do
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Schools::Advice::LongTermUsageService).to receive(:benchmark_usage).and_return(comparison)
    end

    context 'not enough data' do
      let(:enough_data) { false }
      it 'does not benchmark' do
        expect(service.benchmark_school).to be_nil
      end
    end
    context 'with a comparison' do
      it 'returns the comparison category' do
        expect(service.benchmark_school).to eq :benchmark_school
      end
    end
  end
end
