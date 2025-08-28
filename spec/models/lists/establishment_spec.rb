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
      it 'identifies open establishment' do
        est_current = create(:establishment)
        expect(est_current.open?).to be(true)
      end

      it 'identifies closed establishment' do
        est_old = create(:closed_establishment)
        expect(est_old.closed?).to be(true)
      end

      it 'finds successor establishment' do
        est_old = create(:closed_establishment)
        est_new = create(:establishment)
        create(:establishment_link, establishment: est_old, linked_establishment: est_new)
        expect(est_old.successor).to eq(est_new)
      end

      it 'finds latest establishment' do
        est_oldest = create(:closed_establishment)
        est_old = create(:closed_establishment)
        est_current = create(:establishment)
        create(:establishment_link, establishment: est_oldest, linked_establishment: est_old)
        create(:establishment_link, establishment: est_old, linked_establishment: est_current)
        expect(est_oldest.current_establishment).to eq(est_current)
      end

      it 'doesn\'t use links for open establishment' do
        est_current = create(:establishment)
        est_newer = create(:establishment)
        create(:establishment_link, establishment: est_current, linked_establishment: est_newer)
        expect(est_current.current_establishment).to eq(est_current)
      end
    end
  end
end
