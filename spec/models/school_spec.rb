require 'rails_helper'

describe School do
  it 'builds a slug on create using :name' do
    school = create :school
    expect(school.slug).to eq(school.name.parameterize)
  end
  context 'when two schools have the same name' do
    it 'builds a different slug using :postcode and :name' do
      school = (create_list :school, 2).last
      expect(school.slug).to eq([school.postcode, school.name].join('-').parameterize)
    end
  end
  context 'when three schools have the same name and postcode' do
    it 'builds a different slug using :urn and :name' do
      school = (create_list :school, 3).last
      expect(school.slug).to eq([school.urn, school.name].join('-').parameterize)
    end
  end
end
