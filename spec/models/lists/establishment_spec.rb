require 'rails_helper'

module Lists
  describe Establishment do
    it_behaves_like 'a csvimportable', './spec/fixtures/import_establishments/zipped_sample.zip'

    describe '.import' do
      context 'with empty database' do
        before do
          File.open('./spec/fixtures/import_establishments/establishments_sample.csv') do |file|
            described_class.import(file.read, 1000)
          end
        end

        it 'converts integers' do
          expect(described_class.find(100000).number_of_pupils).to eq(249)
        end

        it 'converts datetimes' do
          expect(described_class.find(100000).last_changed_date).to eq(DateTime.parse('07-07-2025'))
        end

        it 'imports non-ascii characters' do
          expect(described_class.find(100371).establishment_name).to eq('Ecole Française de Londres Jacques Prévert')
        end
      end

      context 'with existing records' do
        before do
          build(:establishment, id: 100000).save
          File.open('./spec/fixtures/import_establishments/establishments_sample.csv') do |file|
            described_class.import(file.read, 1000)
          end
        end

        it 'updates columns' do
          expect(described_class.find(100000).number_of_pupils).to eq(249)
        end
      end
    end

    describe 'uses links correctly' do
      before do
        create(:closed_establishment, id: 1)
        create(:closed_establishment, id: 2)
        create(:establishment, id: 3)
        create(:establishment, id: 4)
        create(:establishment_link_successor, establishment_id: 1, linked_establishment_id: 2)
        create(:establishment_link_successor, establishment_id: 2, linked_establishment_id: 3)
        create(:establishment_link_successor, establishment_id: 3, linked_establishment_id: 4)
      end

      it 'identifies open establishment' do
        expect(described_class.find(3).open?).to be(true)
      end

      it 'identifies closed establishment' do
        expect(described_class.find(1).closed?).to be(true)
      end

      it 'finds successor' do
        expect(described_class.find(1).successor).to eq(described_class.find(2))
      end

      it 'finds latest establishment' do
        expect(described_class.find(1).current_establishment).to eq(described_class.find(3))
      end

      it 'doesn\'t use links for up-to-date establishment' do
        expect(described_class.find(3).current_establishment).to eq(described_class.find(3))
      end
    end
  end
end
