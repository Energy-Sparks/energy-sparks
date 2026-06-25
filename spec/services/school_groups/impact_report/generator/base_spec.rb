# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Base do
  subject(:generator) { described_class.new(school_group, visible_schools) }

  let(:school_group) { create(:school_group) }
  let(:visible_schools) { school_group.assigned_schools.visible }
  let!(:visible_school) { create(:school, data_enabled: false, school_group:) }
  let!(:data_visible_school) { create(:school, school_group:) }

  describe '#visible_schools' do
    it 'returns only visible schools assigned to the school group' do
      expect(generator.send(:visible_schools)).to contain_exactly(visible_school, data_visible_school)
    end
  end

  describe '#data_visible_schools' do
    before { create(:school, :with_school_group) }

    it 'returns only data-visible schools assigned to the school group' do
      expect(generator.send(:data_visible_schools)).to eq([data_visible_school])
    end
  end
end
