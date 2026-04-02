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
end
