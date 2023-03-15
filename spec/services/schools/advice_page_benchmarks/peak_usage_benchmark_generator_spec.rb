require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::PeakUsageBenchmarkGenerator, type: :service do

  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :electricity_intraday, fuel_type: :electricity) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service)     { Schools::AdvicePageBenchmarks::PeakUsageBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  context '#benchmark_school' do
    let(:enough_data) { true }
    let(:comparison) {
      Schools::Comparison.new(
        school_value: 62.0,
        benchmark_value: 75.0,
        exemplar_value: 50.0,
        unit: :kw
      )
    }
    before(:each) do
      allow_any_instance_of(Schools::Advice::PeakUsageService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Schools::Advice::PeakUsageService).to receive(:benchmark_peak_usage).and_return(comparison)
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
