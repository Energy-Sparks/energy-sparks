require 'rails_helper'

describe Schools::SchoolMetricsGeneratorService, type: :service do

  let!(:benchmark_run)    { BenchmarkResultGenerationRun.create! }

  let(:school)            { create(:school) }
  #this will create an empty meter collection as the school has no data
  let(:meter_collection)  { Amr::AnalyticsMeterCollectionFactory.new(school).validated }

  subject(:service)       { Schools::SchoolMetricsGeneratorService.new(school: school, meter_collection: meter_collection)}

  let(:stub)              { double('service_stub') }

  describe '#perform' do

    context 'it should update school configuration' do
      before do
        expect(Schools::GenerateConfiguration).to receive(:new).with(school, anything).and_return(stub)
        expect(stub).to receive(:generate)
      end
      it 'runs the benchmarks' do
        service.perform
      end
    end

    context 'it should update alerts and benchmarks' do
      context 'it should run the service' do
        before(:each) do
          expect(Alerts::GenerateAndSaveAlertsAndBenchmarks).to receive(:new).with(school: school, aggregate_school: anything, benchmark_result_generation_run: benchmark_run).and_return(stub)
          expect(stub).to receive(:perform).once
        end

        it 'should run alerts and benchmarks' do
          service.perform
        end
      end

      it 'should store school specific benchmarks' do
        service.perform
        expect(BenchmarkResultSchoolGenerationRun.last.benchmark_result_generation_run).to eq(benchmark_run)
      end
    end

    context 'it should update equivalences' do
      before(:each) do
        expect(Equivalences::GenerateEquivalences).to receive(:new).with(school: school, aggregate_school: anything).and_return(stub)
        expect(stub).to receive(:perform).once
      end

      it 'should run alerts and benchmarks' do
        service.perform
      end
    end


    context 'it should generate school content' do
      before(:each) do
        expect(Alerts::GenerateContent).to receive(:new).with(school).and_return(stub)
        expect(stub).to receive(:perform).once
      end

      it 'should run alerts and benchmarks' do
        service.perform
      end
    end

    context 'when school has a target' do
      let!(:school_target) { create(:school_target, school: school) }
      before do
        service.perform
      end
      it 'should end up updated' do
        school_target.reload
        expect(school_target.report_last_generated).to_not be_nil
      end
    end

    context 'it should run advice page benchmarks' do
      before(:each) do
        expect(Schools::AdvicePageBenchmarks::GenerateBenchmarks).to receive(:new).with(school: school, aggregate_school: anything).and_return(stub)
        expect(stub).to receive(:generate!).once
      end
      it 'runs the benchmarks' do
        service.perform
      end
    end

  end


end
