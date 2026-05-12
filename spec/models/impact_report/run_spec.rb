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
    let!(:metric) { create(:impact_report_metric, impact_report_run: run) }

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

  describe '#metric' do
    let(:run) { create(:impact_report_run) }

    let!(:metric) do
      create(
        :impact_report_metric,
        impact_report_run: run,
        metric_category: 'overview',
        metric_type: 'active_users',
        value: 42
      )
    end

    it 'returns the matching metric by category and type' do
      expect(run.metric(:overview, :active_users)).to eq(metric)
    end

    it 'returns nil if no metric matches' do
      expect(run.metric(:overview, :missing)).to be_nil
    end
  end

  describe 'category helpers (e.g. #overview)' do
    let(:run) { create(:impact_report_run) }

    let!(:metric) do
      create(
        :impact_report_metric,
        impact_report_run: run,
        metric_category: 'overview',
        metric_type: 'active_users',
        value: 10
      )
    end

    it 'delegates to #metric via dynamic method' do
      expect(run.overview(:active_users)).to eq(metric)
    end
  end

  describe 'metrics indexing' do
    let(:run) { create(:impact_report_run) }

    let!(:active_users) do
      create(:impact_report_metric,
             impact_report_run: run,
             metric_category: 'overview',
             metric_type: 'active_users')
    end

    let!(:users) do
      create(:impact_report_metric,
             impact_report_run: run,
             metric_category: 'overview',
             metric_type: 'users')
    end

    it 'indexes metrics by category and type' do
      expect(run.metric(:overview, :active_users)).to eq(active_users)
      expect(run.metric(:overview, :users)).to eq(users)
    end

    it 'memoizes the index' do
      expect(run.send(:metrics_index)).to equal(run.send(:metrics_index))
    end
  end
end
