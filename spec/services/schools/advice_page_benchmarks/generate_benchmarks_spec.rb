require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::GenerateBenchmarks, type: :service do
  let(:advice_page_1) { create(:advice_page, key: :baseload) }
  let(:advice_page_2) { create(:advice_page, key: :electricity_out_of_hours) }

  let(:school)        { create(:school) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service)       { Schools::AdvicePageBenchmarks::GenerateBenchmarks.new(school: school, aggregate_school: aggregate_school) }

  let(:generator)     { double('generator') }

  describe '#generate!' do
    before do
      expect(Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator).to receive(:generator_for).with(advice_page: advice_page_1, school: school, aggregate_school: aggregate_school).and_return(generator)
      expect(Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator).to receive(:generator_for).with(advice_page: advice_page_2, school: school, aggregate_school: aggregate_school).and_return(generator)
      expect(generator).to receive(:perform).twice
    end

    it 'processes all pages' do
      service.generate!
    end
  end
end
