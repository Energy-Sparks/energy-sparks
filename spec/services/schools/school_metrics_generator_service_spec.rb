require 'rails_helper'

describe Schools::SchoolMetricsGeneratorService, type: :service do

  let!(:benchmark_run)    { BenchmarkResultGenerationRun.create! }

  let(:school)            { create(:school) }
  #this will create an empty meter collection as the school has no data
  let(:meter_collection)  { Amr::AnalyticsMeterCollectionFactory.new(school).validated }

  subject(:service)       { Schools::SchoolMetricsGeneratorService.new(school: school, meter_collection: meter_collection)}

  let(:stub)              { double('service_stub') }

  describe '#perform' do
    context 'when updating school configuration' do
      it 'runs the service' do
        expect(Schools::GenerateConfiguration).to receive(:new).with(school, anything).and_return(stub)
        expect(stub).to receive(:generate)
        service.perform
      end
    end

    context 'when running alerts and benchmarks' do
      it 'runs the service' do
        expect(Alerts::GenerateAndSaveAlertsAndBenchmarks).to receive(:new).with(school: school, aggregate_school: anything, benchmark_result_generation_run: benchmark_run).and_return(stub)
        expect(stub).to receive(:perform).once
        service.perform
      end

      it 'stores school specific benchmarks' do
        service.perform
        expect(BenchmarkResultSchoolGenerationRun.last.benchmark_result_generation_run).to eq(benchmark_run)
      end
    end

    context 'when generating equivalences' do
      it 'runs the service' do
        expect(Equivalences::GenerateEquivalences).to receive(:new).with(school: school, aggregate_school: anything).and_return(stub)
        expect(stub).to receive(:perform).once
        service.perform
      end
    end

    context 'when generating content' do
      it 'runs the service' do
        expect(Alerts::GenerateContent).to receive(:new).with(school).and_return(stub)
        expect(stub).to receive(:perform).once
        service.perform
      end
    end

    context 'when updating school targets' do
      let!(:school_target) { create(:school_target, school: school) }
      before do
        service.perform
      end
      it 'updates the target' do
        school_target.reload
        expect(school_target.report_last_generated).to_not be_nil
      end
    end

    context 'when generating advice page benchmarks' do
      it 'runs the service' do
        expect(Schools::AdvicePageBenchmarks::GenerateBenchmarks).to receive(:new).with(school: school, aggregate_school: anything).and_return(stub)
        expect(stub).to receive(:generate!).once
        service.perform
      end
    end

  end


end
