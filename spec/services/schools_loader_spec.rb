require 'rails_helper'

describe SchoolsLoader, type: :service do
  let(:filepath)  { 'foo' }
  let(:service)   { SchoolsLoader.new(filepath) }

  describe '#schools' do
    let!(:school_1) { create(:school, name: 'zulu', school_group: nil) }
    let!(:school_2) { create(:school, name: 'alpha', school_group: nil) }

    let(:data) { { 'schools' => [{ 'name' => school_1.slug, 'description' => 'foo' }, { 'name' => school_2.slug, 'description' => 'bar' }] } }

    context 'with no list' do
      it 'returns empty list' do
        schools = service.schools
        expect(schools).to eq([])
      end
    end

    context 'with specified list' do
      let(:filepath) { Tempfile.new.tap { |f| f << data.to_yaml; f.close } }

      it 'loads the named schools in order' do
        schools = service.schools
        expect(schools.map(&:name)).to eq(%w[alpha zulu])
      end

      context 'with named school also in group' do
        before do
          school_1.update(school_group: create(:school_group))
        end

        it 'deduplicates the schools' do
          schools = service.schools
          expect(schools.count).to eq(2)
        end
      end
    end

    context 'with schools from groups' do
      let!(:school_group_1) { create(:school_group) }
      let!(:school_1_1)     { create(:school, name: 'foxtrot', school_group: school_group_1) }
      let!(:school_1_2)     { create(:school, name: 'echo', school_group: school_group_1) }
      let!(:school_1_3)     { create(:school, name: 'delta', school_group: school_group_1) }

      let!(:school_group_2) { create(:school_group) }
      let!(:school_2_1)     { create(:school, name: 'golf', school_group: school_group_2) }

      it 'loads first 2 schools by name from each group' do
        schools = service.schools
        expect(schools.map(&:name)).to eq(%w[delta echo golf])
      end

      context 'with specified list as well as groups' do
        let(:filepath) { Tempfile.new.tap { |f| f << data.to_yaml; f.close } }

        it 'loads all schools in order' do
          schools = service.schools
          expect(schools.map(&:name)).to eq(%w[alpha delta echo golf zulu])
        end
      end
    end
  end

  describe 'when loading the real config file' do
    let(:filepath) { Rails.root.join('config/test_schools.yml') }

    it 'gets valid list of schools' do
      slugs = service.school_slugs
      expect(slugs).not_to be_empty
    end
  end
end
