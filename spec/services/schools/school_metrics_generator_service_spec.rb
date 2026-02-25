require 'rails_helper'

describe Schools::SchoolMetricsGeneratorService, type: :service do
  subject(:service) { Schools::SchoolMetricsGeneratorService.new(school:, meter_collection:) }

  let(:school) { create(:school) }
  let(:meter_collection) { build(:meter_collection, :with_aggregate_meter) }
  let(:stub) { double('service_stub') }

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
        expect(Alerts::GenerateAndSaveAlertsAndBenchmarks).to receive(:new).with(school: school,
                                                                                 aggregate_school: anything).and_return(stub)
        expect(stub).to receive(:perform).once
        service.perform
      end
    end

    context 'when generating equivalences' do
      it 'runs the service' do
        expect(Equivalences::GenerateEquivalences).to receive(:new).with(school: school,
                                                                         aggregate_school: anything).and_return(stub)
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
        expect(school_target.reload.report_last_generated).not_to be_nil
      end
    end

    context 'when generating advice page benchmarks' do
      it 'runs the service' do
        expect(Schools::AdvicePageBenchmarks::GenerateBenchmarks).to \
          receive(:new).with(school:, aggregate_school: anything).and_return(stub)
        expect(stub).to receive(:generate!).once
        service.perform
      end
    end

    context 'when an error it thrown' do
      before do
        allow(Alerts::GenerateContent).to receive(:new).and_raise
      end

      it 'does not raise' do
        expect { service.perform }.not_to raise_error
      end
    end
  end
end
