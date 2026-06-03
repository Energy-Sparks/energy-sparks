# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport do
  subject(:report) { described_class.new(school_group) }

  let(:school_group) { create(:school_group) }
  let!(:visible_school) { create(:school, data_enabled: false, school_group:) }
  let!(:data_visible_school) { create(:school, school_group:) }

  describe '#visible_schools' do
    it 'returns only visible schools assigned to the school group' do
      expect(report.visible_schools).to contain_exactly(visible_school, data_visible_school)
    end
  end

  describe '#data_visible_schools' do
    before { create(:school, :with_school_group) }

    it 'returns only data-visible schools assigned to the school group' do
      expect(report.data_visible_schools).to eq([data_visible_school])
    end
  end
end
