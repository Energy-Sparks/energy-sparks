require 'rails_helper'

RSpec.describe Schools::CountryLookup do
  let!(:school)           { create(:school, postcode: postcode) }
  let!(:service)          { Schools::CountryLookup.new(school) }

  context 'when postcode is in england' do
    let!(:postcode) { 'NG1 1EQ' }

    it 'finds england' do
      expect(service.country).to eq(:england)
    end
  end

  context 'when postcode is in wales' do
    let!(:postcode) { 'CF10 1AE' }

    it 'finds england' do
      expect(service.country).to eq(:wales)
    end
  end

  context 'when postcode is in scotland' do
    let!(:postcode) { 'EH1 1AA' }

    it 'finds england' do
      expect(service.country).to eq(:scotland)
    end
  end

  context 'when postcode is not recognised' do
    let!(:postcode) { 'AA1 1ZZ' }

    it 'defaults to england' do
      expect(service.country).to eq(:england)
    end
  end
end
