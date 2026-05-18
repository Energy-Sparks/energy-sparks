# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Metric do
  context 'with valid attributes' do
    let(:metric) { create(:impact_report_metric) }

    it 'is valid' do
      expect(metric).to be_valid
    end

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
