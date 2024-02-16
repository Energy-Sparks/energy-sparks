require 'rails_helper'

describe Comparison::ReportService do
  subject(:service) { described_class.new(definition: definition) }

  include_context 'with some schools and metrics'

  let(:definition) do
    Comparison::ReportDefinition.new(
      metric_type_keys: [metric_type.key.to_sym],
      order_key: metric_type.key.to_sym,
      schools: [school_1, school_2]
    )
  end

  describe '#perform' do
    subject(:result) { service.perform }

    it { expect(result.definition).to eq(definition) }

    context 'with a definition that includes no schools' do
      let(:definition) do
        Comparison::ReportDefinition.new(
          metric_type_keys: [metric_type.key.to_sym],
          order_key: metric_type.key.to_sym,
          schools: []
        )
      end

      it { expect(result.metrics_by_school.empty?).to be true}
    end

    context 'with a definition that includes a limited list of schools' do
      let(:definition) do
        Comparison::ReportDefinition.new(
          metric_type_keys: [metric_type.key.to_sym],
          order_key: metric_type.key.to_sym,
          schools: [school_1]
        )
      end

      it { expect(result.metrics_by_school.keys).to match_array([school_1]) }
    end

    context 'with a definition that includes several schools' do
      let(:definition) do
        Comparison::ReportDefinition.new(
          metric_type_keys: [metric_type.key.to_sym],
          order_key: metric_type.key.to_sym,
          schools: [school_1, school_2]
        )
      end

      it { expect(result.metrics_by_school.keys).to eq([school_2, school_1]) }

      context 'when there are multiple metric types' do
        let(:definition) do
          Comparison::ReportDefinition.new(
            metric_type_keys: [metric_type.key.to_sym, other_metric.metric_type.key.to_sym],
            order_key: metric_type.key.to_sym,
            schools: [school_1, school_2]
          )
        end

        it { expect(result.metrics_by_school[school_1].size).to eq(2) }
        it { expect(result.metrics_by_school[school_2].size).to eq(1) }
      end

      context 'when there is a restriction on alert types' do
        let(:definition) do
          Comparison::ReportDefinition.new(
            metric_type_keys: [metric_type.key.to_sym, other_metric.metric_type.key.to_sym],
            order_key: metric_type.key.to_sym,
            alert_types: metric_1.alert_type,
            schools: [school_1, school_2]
          )
        end

        it { expect(result.metrics_by_school.keys).to eq([school_1]) }
        it { expect(result.metrics_by_school[school_1].size).to eq(1) }
      end

      context 'when there is an alternate order' do
        let(:definition) do
          Comparison::ReportDefinition.new(
            metric_type_keys: [metric_type.key.to_sym],
            order_key: metric_type.key.to_sym,
            schools: [school_1, school_2],
            order: :asc
          )
        end

        it { expect(result.metrics_by_school.keys).to eq([school_1, school_2]) }
      end
    end
  end
end
