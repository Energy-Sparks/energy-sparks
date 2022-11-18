require 'rails_helper'

describe UnvalidatedDataSchoolsLoader, type: :service do

  let(:service) { UnvalidatedDataSchoolsLoader.new(filepath) }

  describe '#schools' do

    let!(:school_1) { create(:school) }
    let!(:school_2) { create(:school) }

    let(:data)        { [ { 'name' => school_1.slug, 'description' => 'foo' }, { 'name' => school_2.slug, 'description' => 'bar' } ] }
    let(:filepath)    { Tempfile.new.tap {|f| f << data.to_yaml; f.close } }

    it 'loads the named schools' do
      schools = service.schools
      expect(schools.count).to eq(2)
    end
  end

  describe '#school_slugs' do
    let(:filepath)    { Rails.root.join('config/unvalidated_data_schools.yml') }
    it 'gets valid list of schools' do
      slugs = service.school_slugs
      expect(slugs).not_to be_empty
    end
  end
end
