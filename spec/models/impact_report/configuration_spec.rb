# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Configuration do
  context 'with valid attributes' do
    let(:config) { create(:impact_report_configuration) }

    it 'is valid' do
      expect(config).to be_valid
    end

    it 'belongs to school_group' do
      expect(config).to belong_to(:school_group)
    end
  end

  describe 'default values' do
    let(:config) { create(:impact_report_configuration) }

    it 'has show_engagement default to true' do
      expect(config.show_engagement).to be true
    end
  end
end
