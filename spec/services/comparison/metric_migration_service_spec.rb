require 'rails_helper'

# rubocop:disable RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock
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
# rubocop:enable RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock

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
    context 'when the alert type has a fuel type' do
      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: :electricity, class_name: 'AlertElectricityBaseloadVersusBenchmark')
      end

      it { expect(service.fuel_type_for_metric_type(:unknown, {}, alert_type)).to eq :electricity }
      it { expect(service.fuel_type_for_metric_type(:gas_annual_kwh, { units: :unknown }, alert_type)).to eq :electricity }
      it { expect(service.fuel_type_for_metric_type(:annual_kw, { units: { kw: :gas } }, alert_type)).to eq :electricity }
    end

    context 'when the alert type has no fuel type' do
      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: nil, class_name: 'AlertEnergyAnnualVersusBenchmark')
      end

      context 'with a fuel type in the analytics metric definition' do
        it { expect(service.fuel_type_for_metric_type(:annual_kw, { units: { kw: :gas } }, alert_type)).to eq :gas }
      end

      context 'when the metric name includes a fuel type' do
        it { expect(service.fuel_type_for_metric_type(:annual_electricity_kwh, { units: :kwh }, alert_type)).to eq :electricity }
        it { expect(service.fuel_type_for_metric_type(:annual_solar_kwh, { units: :kwh }, alert_type)).to eq :solar_pv }
        it { expect(service.fuel_type_for_metric_type(:annual_gas_kwh, { units: :kwh }, alert_type)).to eq :gas }
        it { expect(service.fuel_type_for_metric_type(:annual_storage_heaters_kwh, { units: :kwh }, alert_type)).to eq :storage_heater }
      end

      context 'when there is no other fuel type' do
        it { expect(service.fuel_type_for_metric_type(:annual_kwh, { units: :kwh }, alert_type)).to eq :multiple }
      end
    end
  end

  describe '#key_for_metric' do
    let!(:alert_type) do
      create(:alert_type, enabled: true, class_name: 'AlertElectricityBaseloadVersusBenchmark')
    end

    it { expect(service.key_for_metric(alert_type, :rating)).to eq(:alertelectricitybaseloadversusbenchmark_rating) }
    it { expect(service.key_for_metric(alert_type, :other)).to eq(:other) }
    it { expect(service.key_for_metric(alert_type, :annual_baseload_£)).to eq(:annual_baseload_gbp) }
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
      let!(:alert_type) do
        create(:alert_type, enabled: true,
          fuel_type: :electricity, class_name: 'TestAlert')
      end

      it 'correctly creates the metric types' do
        service.migrate
        metric = Comparison::MetricType.order(:key).first
        expect(metric.key.to_sym).to eq(:benchmark_per_pupil)
        expect(metric.label).to eq('benchmark_per_pupil description')
        expect(metric.units.to_sym).to eq :kwh

        # from base class
        metric = Comparison::MetricType.order(:key).last
        # renamed from :rating
        expect(metric.key.to_sym).to eq(:testalert_rating)
        expect(metric.label).to eq('Rating out of 10')
        expect(metric.units.to_sym).to eq :float
      end

      it 'does not create ignored metrics' do
        service.migrate
        expect(Comparison::MetricType.count).to eq(2)
      end
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
