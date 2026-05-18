# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Run do
  context 'with valid attributes' do
    let(:run) { create(:impact_report_run) }

    it 'is valid' do
      expect(run).to be_valid
    end

    it 'belongs to school_group' do
      expect(run).to belong_to(:school_group)
    end

    it 'has many metrics dependent destroy' do
      expect(run).to have_many(:metrics).dependent(:destroy)
    end
  end

  describe 'associations' do
    let(:run) { create(:impact_report_run) }
    let!(:metric) { create(:impact_report_metric, run: run) }

    it 'has metrics' do
      expect(run.metrics).to include(metric)
    end
  end

  describe '.latest' do
    subject(:run) { described_class.latest }

    let!(:latest_run) { create(:impact_report_run, run_date: 1.day.ago) }

    before do
      create(:impact_report_run, run_date: 2.days.ago)
    end

    it 'returns the run with the most recent run_date' do
      expect(run).to eq(latest_run)
    end

    it 'includes metrics' do
      expect(run.association(:metrics)).to be_loaded
    end
  end

  describe '#overview' do
    let(:run) { create(:impact_report_run) }

    let!(:metric) do
      create(
        :impact_report_metric,
        run: run,
        metric_category: 'overview',
        metric_type: 'active_users',
        value: 10
      )
    end

    it 'delegates to #metric via dynamic method' do
      expect(run.overview(:active_users)).to eq(metric)
    end
  end

  describe '#engagement' do
    let(:run) { create(:impact_report_run) }

    let!(:metric) do
      create(
        :impact_report_metric,
        run: run,
        metric_category: 'engagement',
        metric_type: 'points',
        value: 10
      )
    end

    it 'delegates to #metric via dynamic method' do
      expect(run.engagement(:points)).to eq(metric)
    end
  end

  describe '#potential_savings' do
    let(:metric_category) { :potential_savings }

    context 'when ignoring irrelevant metrics' do
      subject(:run) { create(:impact_report_run) }

      let(:fuel_type) { :electricity }
      let!(:non_gbp_metric) do
        create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :baseload_kwh)
      end
      let!(:zero_metric) do
        create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :out_of_hours_gbp, value: 0)
      end
      let!(:no_data_metric) do
        create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :peak_gbp, enough_data: false)
      end
      let!(:ok_metric) { create(:impact_report_metric, run:, metric_category:, fuel_type:, metric_type: :baseload_gbp) }

      it 'includes nonzero gbp metrics with enough_data' do
        expect(run.potential_savings).to include(ok_metric)
      end

      it 'filters out non-gbp metrics' do
        expect(run.potential_savings).not_to include(non_gbp_metric)
      end

      it 'filters out zero metrics' do
        expect(run.potential_savings).not_to include(zero_metric)
      end

      it 'filters out metrics without enough_data' do
        expect(run.potential_savings).not_to include(no_data_metric)
      end
    end

    context 'when sorting metrics' do
      subject(:potential_savings) { run.potential_savings.map(&:metric_type) }

      let(:run) { create(:impact_report_run) }

      def create_metric(metric_type, fuel_type, value)
        create(:impact_report_metric, run:, metric_category:, fuel_type:, value:, metric_type:)
      end

      context 'when there are only electricity metrics' do
        let(:fuel_type) { :electricity }

        before do
          create_metric(:baseload_gbp, :electricity, 3)
          create_metric(:out_of_hours_gbp, :electricity, 4)
        end

        it 'returns metrics with the highest value first' do
          expect(potential_savings).to eq(%w[out_of_hours_gbp baseload_gbp])
        end
      end

      context 'when there are 2 electicity metrics and a gas metric' do
        before do
          create_metric(:baseload_gbp, :electricity, 3)
          create_metric(:out_of_hours_gbp, :electricity, 4)
          create_metric(:insulate_pipes_gbp, :gas, 3)
        end

        it 'returns highest electricity, then gas, then next elec' do
          expect(potential_savings).to eq(%w[out_of_hours_gbp insulate_pipes_gbp baseload_gbp])
        end
      end

      context 'when there are 2 electricity metrics and a solar metric' do
        before do
          create_metric(:baseload_gbp, :electricity, 3)
          create_metric(:out_of_hours_gbp, :electricity, 4)
          create_metric(:solar_panels_gbp, :solar_pv, 3)
        end

        it 'returns highest electricity, then solar, then next elec' do
          expect(potential_savings).to eq(%w[out_of_hours_gbp solar_panels_gbp baseload_gbp])
        end
      end
    end
  end

  describe 'metrics indexing' do
    subject(:index) { run.send(:metrics_index) }

    let(:run) { create(:impact_report_run) }

    let!(:active_users) do
      create(:impact_report_metric,
             run: run,
             metric_category: 'overview',
             metric_type: 'active_users')
    end

    let!(:points) do
      create(:impact_report_metric,
             run: run,
             metric_category: 'engagement',
             metric_type: 'points')
    end

    let!(:baseload_gbp) do
      create(:impact_report_metric,
             run: run,
             fuel_type: 'electricity',
             metric_category: 'potential_savings',
             metric_type: 'baseload_gbp')
    end

    it 'memoizes the index' do
      expect(index).to equal(run.send(:metrics_index))
    end

    it 'stores overview metrics in a hash' do
      expect(index['overview']['active_users']).to equal(active_users)
    end

    it 'stores engagemement metrics in a hash' do
      expect(index['engagement']['points']).to equal(points)
    end

    it 'stores potential savings metrics in an array' do
      expect(index['potential_savings']['electricity']).to eq([baseload_gbp])
    end
  end
end
