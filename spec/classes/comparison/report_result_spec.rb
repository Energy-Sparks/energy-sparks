require 'rails_helper'

describe Comparison::ReportResult do
  subject(:result) do
    described_class.new(
      definition: definition,
      metrics_by_school: metrics_by_school
    )
  end

  let(:definition) { build(:report_definition) }
  let(:metrics_by_school) { {} }

  let!(:metric_type) { create(:metric_type, units: :float) }
  let!(:metric) { create(:metric, metric_type: metric_type) }

  describe '#schools' do
    context 'when there are no results' do
      it { expect(result.schools).to be_empty }
    end

    context 'when there are results' do
      let(:metrics_by_school) do
        { metric.school => [metric] }.to_h
      end

      it { expect(result.schools).to eq([metric.school]) }
    end
  end

  describe '#metric' do
    context 'with results' do
      let(:school) { metric.school }
      let(:metrics_by_school) do
        { school => [metric] }.to_h
      end

      it { expect(result.metric(school, metric_type.key.to_sym)).to eq metric }

      context 'with unknown metric' do
        it { expect(result.metric(school, :unknown)).to eq nil }
      end
    end
  end

  describe '#format_metric' do
    let(:school) { metric.school }
    let(:metrics_by_school) do
      { school => [metric] }.to_h
    end

    it { expect(result.format_metric(school, metric_type.key.to_sym)).to eq metric.value }

    context 'with a :kwh type' do
      let!(:metric_type) { build(:metric_type, units: :kwh) }

      it { expect(result.format_metric(school, metric_type.key.to_sym)).to eq metric.value.to_s }
    end
  end
end
