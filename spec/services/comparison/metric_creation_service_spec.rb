require 'rails_helper'

# rubocop:disable RSpec/LeakyConstantDeclaration
# rubocop:disable Lint/ConstantDefinitionInBlock
class TestAlert < AlertAnalysisBase
  VARIABLES = {
    benchmark_per_pupil: {
      description: 'benchmark_per_pupil description',
      units: :kwh,
      benchmark_code: 'abc'
    },
    school_name: {
      description: 'should be ignored',
      units: String,
      benchmark_code: 'xyz'
    }
  }.freeze

  def self.template_variables
    { 'Test Vars' => VARIABLES }.merge(self.superclass.template_variables)
  end
end
# rubocop:enable RSpec/LeakyConstantDeclaration
# rubocop:enable Lint/ConstantDefinitionInBlock

describe Comparison::MetricCreationService, :aggregate_failures do
  subject(:service) do
    described_class.new(
      benchmark_result_school_generation_run: run,
      alert_type: alert_type,
      alert_report: alert_report,
      asof_date: asof_date
      )
  end

  let!(:run) { create(:benchmark_result_school_generation_run) }
  let!(:alert_type) do
    create(:alert_type, enabled: true,
      fuel_type: :electricity, class_name: 'TestAlert')
  end
  let(:asof_date) { Time.zone.today }
  let(:valid) { true }

  let(:alert_report_attributes) do
    {
      valid: valid,
      rating: 5.0,
      relevance: :relevant,
      enough_data: :enough,
      benchmark_data: { benchmark: 'variables', var: Float::INFINITY },
      benchmark_data_cy: { benchmark: 'welsh-variables', var: Float::INFINITY },
      analysis_object: analysis_object
    }
  end

  let(:alert_report) { Alerts::Adapters::Report.new(**alert_report_attributes) }
  let(:analysis_object) { instance_double('alert') }

  shared_examples 'a successful execution' do |count:, enough: true, recent: true|
    it 'has the created the right number of metrics' do
      expect(Comparison::Metric.count).to eq(count)
    end

    it 'has correctly populated the metric attributes' do
      expect(Comparison::Metric.first.school).to eq(run.school)
      expect(Comparison::Metric.first.benchmark_result_school_generation_run).to eq(run)
      expect(Comparison::Metric.first.alert_type).to eq(alert_type)
      expect(Comparison::Metric.first.reporting_period.to_sym).to eq(:last_12_months)
      expect(Comparison::Metric.first.enough_data).to eq(enough)
      expect(Comparison::Metric.first.asof_date).to eq(asof_date)
      expect(Comparison::Metric.first.whole_period).to eq(true)
      expect(Comparison::Metric.first.recent_data).to eq(recent)
    end
  end

  describe '#perform' do
    context 'when alert type should be ignored' do
      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: :electricity, class_name: 'AlertLayerUpPowerdown11November2022ElectricityComparison')
      end

      it { expect(service.perform).to eq(false) }

      it 'doesnt create metrics' do
        service.perform
        expect(Comparison::Metric.count).to eq(0)
      end
    end

    context 'with an alert that is not relevant for school' do
      before do
        allow(analysis_object).to receive(:valid_content?).and_return(false)
      end

      it { expect(service.perform).to eq(false) }

      it 'doesnt create metrics' do
        service.perform
        expect(Comparison::Metric.count).to eq(0)
      end
    end

    context 'with a relevant alert' do
      let(:enough_data) { :enough }
      let(:recent_data) { true }

      before do
        create(:metric_type, key: :benchmark_per_pupil, fuel_type: :electricity)
        allow(analysis_object).to receive_messages({
          valid_content?: true,
          enough_data: enough_data,
          meter_readings_up_to_date_enough?: recent_data
        })
      end

      context 'when there is an invalid analysis' do
        let(:valid) { false }

        before { service.perform }

        it_behaves_like 'a successful execution', count: 1
      end

      context 'when there wasnt enough data' do
        let(:valid) { false }
        let(:enough_data) { :not_enough }

        before { service.perform }

        it_behaves_like 'a successful execution', count: 1, enough: false
      end

      context 'when the data was stale' do
        let(:valid) { false }
        let(:recent_data) { false }

        before { service.perform }

        it_behaves_like 'a successful execution', count: 1, recent: false
      end

      context 'when the alert was successfully run' do
        let(:valid) { true }
        let(:value) { 0.5 }

        before do
          allow(analysis_object).to receive(:benchmark_per_pupil).and_return(value)
          allow(analysis_object).to receive(:rating).and_return(0.7)
          service.perform
        end

        it_behaves_like 'a successful execution', count: 1
        it 'has stored the value' do
          metric = Comparison::Metric.find_by(
            metric_type: Comparison::MetricType.find_by(key: :benchmark_per_pupil)
          )
          # TODO
          expect(metric.value).to eq('0.5')
        end
      end
    end
  end

  describe '#ignore_alert_type?' do
    it 'returns false' do
      expect(service.send(:ignore_alert_type?)).to eq(false)
    end

    context 'with an alert with an arbitrary period' do
      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: :electricity, class_name: 'AlertLayerUpPowerdown11November2022ElectricityComparison')
      end

      it 'returns true' do
        expect(service.send(:ignore_alert_type?)).to eq(true)
      end
    end
  end

  describe '#reporting_period' do
    it 'identifies period correctly' do
      expect(service.send(:reporting_period, :unknown, {})).to eq(:last_12_months)
    end

    context 'with other alert types' do
      it 'identifies report correctly'
    end
  end
end
