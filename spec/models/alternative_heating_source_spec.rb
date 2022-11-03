require 'rails_helper'

describe 'AlternativeHeatingSource' do

  let!(:school)      { create(:school) }

  context 'basic validation' do
    it 'allows valid attributes' do
      expect(school.alternative_heating_sources.build(source: 'oil', percent_of_overall_use: 0)).to be_valid
      expect(school.alternative_heating_sources.build(source: 'oil', percent_of_overall_use: 100)).to be_valid
    end

    it 'requires a source to be present' do
      expect(school.alternative_heating_sources.build(percent_of_overall_use: 0)).to_not be_valid
    end

    it 'requires percent_of_overall_use to be between 0 and 100' do
      expect(school.alternative_heating_sources.build(source: 'oil', percent_of_overall_use: -1)).to_not be_valid
      expect(school.alternative_heating_sources.build(source: 'oil', percent_of_overall_use: 101)).to_not be_valid
    end
  end
end
