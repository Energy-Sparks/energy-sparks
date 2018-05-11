require 'rails_helper'
require 'loader/schools.rb'

describe 'Loader::Schools' do
  let!(:sample_file) { 'spec/fixtures/schools-sample.csv' }
  # "URN","Name","Type","Address","Postcode","Website","Ecoschool Status"
  # 109153,"St Saviour’s CofE Junior School","primary","Brookleaze Place, Larkhall, Bath","BA1 6RB","http://www.stsaviours-jun.co.uk/",
  # 109154,"St Saviour’s CofE Infant School","primary","Spring Lane, Larkhall, Bath","BA1 6NY","http://www.stsaviours-infants.org/website","green"
  context 'CSV file does not exist' do
    it 'raises an error' do
      expect {
        Loader::Schools.load!('NOT_VALID.csv')
      }.to raise_error RuntimeError
    end
  end
  context 'URN does not exist in schools table' do
    it 'adds a new school record' do
      expect {
        Loader::Schools.load!(sample_file)
      }.to change(School, :count).by(2)
    end
    it 'sets all fields from the CSV' do
      Loader::Schools.load!(sample_file)
      school = School.last
      expect(school.urn).to eq 109154
      expect(school.name).to eq "St Saviour’s CofE Infant School"
      expect(school.primary?).to be_truthy
      expect(school.address).to eq "Spring Lane, Larkhall, Bath"
      expect(school.postcode).to eq "BA1 6NY"
      expect(school.website).to eq "http://www.stsaviours-infants.org/website"
    end
    it 'creates a new calendar' do
      expect {
        Loader::Schools.load!(sample_file)
      }.to change(Calendar, :count).by(2)
    end
    it 'associates the calendar with the school' do
      Loader::Schools.load!(sample_file)
      expect(School.last.calendar_id).to eq Calendar.last.id
    end
  end
  context 'URN already exists in schools table' do
    it 'does not add a new school record' do
      FactoryBot.create :school, urn: '109154'
      expect {
        Loader::Schools.load!(sample_file)
      }.to change(School, :count).by(1)
    end
    it 'does not change the existing school record' do
      existing = FactoryBot.create :school, urn: '109154', name: 'existing school'
      Loader::Schools.load!(sample_file)
      expect(School.find_by(urn: existing.urn)).to eq existing
    end
  end
end
