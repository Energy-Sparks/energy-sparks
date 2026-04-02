# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Metric do
  context 'with valid attributes' do
    let(:metric) { create(:impact_report_metric) }

    it 'is valid' do
      expect(metric).to be_valid
    end

    it 'belongs to impact_report_run' do
      expect(metric).to belong_to(:impact_report_run)
    end
  end

  describe 'enums' do
    describe '#metric_category' do
      let(:metric) { create(:impact_report_metric, metric_category: :energy_efficiency) }

      it 'is category energy_efficiency' do
        expect(metric).to be_category_energy_efficiency
      end

      context 'when engagement' do
        let(:metric) { create(:impact_report_metric, metric_category: :engagement) }

        it 'is category engagement' do
          expect(metric).to be_category_engagement
        end
      end
    end

    describe '#metric_type' do
      let(:metric) { create(:impact_report_metric, metric_type: :total_saving) }

      it 'is type total_saving' do
        expect(metric).to be_type_total_saving
      end

      context 'when engaged_schools' do
        let(:metric) { create(:impact_report_metric, metric_type: :engaged_schools) }

        it 'is type engaged_schools' do
          expect(metric).to be_type_engaged_schools
        end
      end
    end

    describe '#fuel_type' do
      let(:metric) { create(:impact_report_metric, fuel_type: :electricity) }

      it 'is electricity' do
        expect(metric).to be_electricity
      end

      context 'when gas' do
        let(:metric) { create(:impact_report_metric, fuel_type: :gas) }

        it 'is gas' do
          expect(metric).to be_gas
        end
      end

      context 'when no fuel type' do
        let(:metric) { create(:impact_report_metric, fuel_type: nil) }

        it 'has nil fuel type' do
          expect(metric.fuel_type).to be_nil
        end
      end
    end
  end
end
