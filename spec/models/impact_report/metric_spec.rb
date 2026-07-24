# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Metric do
  describe 'validations' do
    subject(:metric) { create(:impact_report_metric, metric_type: :active_users) }

    it { expect(metric).to be_valid }

    context 'when validates uniqueness of metric_type within specified scope' do
      let(:run) { create(:impact_report_run) }
      let(:metric_category) { :overview }
      let(:metric_type) { :active_users }

      before do
        create(:impact_report_metric, metric_type:, impact_report_run_id: run.id, metric_category:, fuel_type: nil)
      end

      it 'validates uniqueness within the scope' do
        duplicate = build(:impact_report_metric,
                          metric_type:, run:, metric_category:, fuel_type: nil)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:metric_type]).to include('has already been taken')
      end
    end
  end

  context 'with valid attributes' do
    subject(:metric) { create(:impact_report_metric) }

    it 'belongs to run' do
      expect(metric).to belong_to(:run)
    end
  end

  describe '#available?' do
    context 'when enough_data is true and value is present' do
      subject(:metric) { create(:impact_report_metric, value: 10, enough_data: true) }

      it { expect(metric.available?).to be(true) }
    end

    context 'when enough_data is false and value is present' do
      subject(:metric) { create(:impact_report_metric, value: 10, enough_data: false) }

      it { expect(metric.available?).to be(false) }
    end

    context 'when enough_data is false and value is not present' do
      subject(:metric) { create(:impact_report_metric, value: nil, enough_data: false) }

      it { expect(metric.available?).to be(false) }
    end

    context 'when enough_data is true and value is not present' do
      subject(:metric) { create(:impact_report_metric, value: nil, enough_data: true) }

      it { expect(metric.available?).to be(false) }
    end

    context 'when enough_data is true and value is 0' do
      subject(:metric) { create(:impact_report_metric, value: 0, enough_data: true) }

      it { expect(metric.available?).to be(true) }
    end
  end
end
