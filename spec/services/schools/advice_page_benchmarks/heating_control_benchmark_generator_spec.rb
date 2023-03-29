require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::HeatingControlBenchmarkGenerator, type: :service do

  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :heating_control, fuel_type: :gas) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service)     { Schools::AdvicePageBenchmarks::HeatingControlBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  context '#benchmark_school' do
    let(:enough_data) { true }
    let(:comparison) {
      Schools::Comparison.new(
        school_value: 10,
        benchmark_value: 11,
        exemplar_value: 6,
        unit: :days
      )
    }
    before(:each) do
      allow_any_instance_of(Schools::Advice::HeatingControlService).to receive(:enough_data_for_seasonal_analysis?).and_return(enough_data)
      allow_any_instance_of(Schools::Advice::HeatingControlService).to receive(:benchmark_warm_weather_days).and_return(comparison)
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
