require 'rails_helper'

describe Comparison::MetricMigrationService do
  subject(:service) do
    described_class.new
  end

  describe '#units_for_metric_type' do
    it { expect(service.units_for_metric_type(nil)).to eq :float }
    it { expect(service.units_for_metric_type(:£)).to eq :£ }
    it { expect(service.units_for_metric_type(:£current)).to eq :£current }
    it { expect(service.units_for_metric_type(:co2)).to eq :co2 }
    it { expect(service.units_for_metric_type(:kwh)).to eq :kwh }
    it { expect(service.units_for_metric_type(:£_per_kw)).to eq :£_per_kw }
    it { expect(service.units_for_metric_type(:percent)).to eq :percent }
    it { expect(service.units_for_metric_type(:relative_percent)).to eq :relative_percent }
    it { expect(service.units_for_metric_type(Float)).to eq :float }
    it { expect(service.units_for_metric_type(Integer)).to eq :integer }
    it { expect(service.units_for_metric_type(TrueClass)).to eq :boolean }
    it { expect(service.units_for_metric_type(String)).to eq :string }
    it { expect(service.units_for_metric_type(Date)).to eq :date }
    it { expect(service.units_for_metric_type(:kw)).to eq :kw }
    it { expect(service.units_for_metric_type({ kw: :electricity })).to eq :kw }
    it { expect(service.units_for_metric_type(:timeofday)).to eq :string }
  end

  describe '#fuel_type_for_metric_type' do
    it 'does something'
  end

  describe '#migrate' do
    context 'with an alert type without benchmark variables' do
      let!(:alert_type) do
        create(:alert_type, enabled: true, class_name: 'AdviceElectricityMeterBreakdownBase')
      end

      before do
        service.migrate
      end

      it 'does not create anything' do
        expect(Comparison::MetricType.count).to be(0)
      end
    end

    context 'with an test alert' do
      # rubocop:disable RSpec/LeakyConstantDeclaration
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class TestAlert < AlertAnalysisBase
        VARIABLES = {
          benchmark_per_pupil: {
            description: 'benchmark_per_pupil description',
            units: :kwh,
            benchmark_code: 'abc'
          }
        }.freeze

        def self.template_variables
          { 'Test Vars' => VARIABLES }.merge(self.superclass.template_variables)
        end
      end
      # rubocop:enable RSpec/LeakyConstantDeclaration
      # rubocop:enable Lint/ConstantDefinitionInBlock


      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: :electricity, class_name: 'TestAlert')
      end

      it 'creates the expected metric types' do
        service.migrate
        expect(Comparison::MetricType.count).to eq(2)

        metric = Comparison::MetricType.order(:key).first
        expect(metric.key.to_sym).to eq(:benchmark_per_pupil)
        expect(metric.label).to eq('benchmark_per_pupil description')
        expect(metric.units.to_sym).to eq :kwh

        # from base class
        metric = Comparison::MetricType.order(:key).last
        expect(metric.key.to_sym).to eq(:rating)
        expect(metric.label).to eq('Rating out of 10')
        expect(metric.units.to_sym).to eq :float
      end

      it 'does not create ignored metrics'
    end

    context 'with a real alert type that produces benchmarks' do
      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: :electricity, class_name: 'AlertElectricityBaseloadVersusBenchmark')
      end

      it 'creates the expected metric types' do
        service.migrate
        expect(Comparison::MetricType.count).to eq(7)
        metric = Comparison::MetricType.where(key: :average_baseload_last_year_kw, fuel_type: :electricity).first
        expect(metric.label).to eq 'Average baseload last year kW'
        expect(metric.units.to_sym).to eq :kw
      end

      context 'when metric type already exists' do
        let!(:metric_type) do
          create(:metric_type, fuel_type: :electricity, key: :average_baseload_last_year_kw)
        end

        it 'creates the rest' do
          service.migrate
          expect(Comparison::MetricType.count).to eq(7)
        end
      end
    end
  end
end
