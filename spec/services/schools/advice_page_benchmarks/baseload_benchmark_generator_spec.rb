require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::BaseloadBenchmarkGenerator, type: :service do
  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :baseload) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service) { Schools::AdvicePageBenchmarks::BaseloadBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school) }

  describe '#benchmark_school' do
    let(:enough_data) { true }
    let(:comparison) do
      Schools::Comparison.new(
        school_value: 10.0,
        benchmark_value: 15.0,
        exemplar_value: 8.0,
        unit: :kw
      )
    end

    before do
      allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:benchmark_baseload).and_return(comparison)
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
