require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::ThermostaticControlBenchmarkGenerator, type: :service do
  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :thermostatic, fuel_type: :gas) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service) { Schools::AdvicePageBenchmarks::ThermostaticControlBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  describe '#benchmark_school' do
    let(:enough_data) { true }
    let(:comparison) do
      Schools::Comparison.new(
        school_value: 0.75,
        benchmark_value: 0.6,
        exemplar_value: 0.8,
        unit: :r2,
        low_is_good: false
      )
    end

    before do
      allow_any_instance_of(Schools::Advice::ThermostaticAnalysisService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Schools::Advice::ThermostaticAnalysisService).to receive(:benchmark_thermostatic_control).and_return(comparison)
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
