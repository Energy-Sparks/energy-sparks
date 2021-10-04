require 'rails_helper'

describe Cad do

  let(:school)            { create(:school) }
  let(:name)              { 'My new CAD' }
  let(:device_identifier) { 'abc123' }

  describe 'validation' do
    it 'saves if good' do
      expect {
        Cad.create!(school: school, name: name, device_identifier: device_identifier)
      }.to change(Cad, :count).by(1)
      expect(school.cads.last.name).to eq(name)
    end

    it 'rejects if missing fields' do
      expect(Cad.new(school: nil, name: name, device_identifier: 'abc123')).to_not be_valid
      expect(Cad.new(school: school, name: '', device_identifier: 'abc123')).to_not be_valid
      expect(Cad.new(school: school, name: name, device_identifier: '')).to_not be_valid
    end
  end
end
