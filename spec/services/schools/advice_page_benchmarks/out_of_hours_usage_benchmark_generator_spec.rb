require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::OutOfHoursUsageBenchmarkGenerator, type: :service do
  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :electricity_out_of_hours, fuel_type: :electricity) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service) { Schools::AdvicePageBenchmarks::OutOfHoursUsageBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school) }

  describe '#benchmark_school' do
    let(:enough_data) { true }

    before do
      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:annual_out_of_hours_kwh).and_return({
                                                                                                                  out_of_hours: 12,
                                                                                                                  total_annual: 40
                                                                                                                })
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
