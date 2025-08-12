require 'rails_helper'

module Lists
  describe Establishment do
    describe '.convert_header' do
      it 'converts headers to snakecase correctly' do
        expect(Establishment.convert_header('EstablishmentName (code)')).to eq('establishment_name_code')
      end
    end

    describe '.read_data_csv_from_zip' do
      it 'finds data csv in zip file' do
        expect {Establishment.read_data_csv_from_zip('./spec/fixtures/import_establishments/example_zip_file.zip')}.not_to raise_error
      end

      it 'throws error when no data csv is found' do
        expect {Establishment.read_data_csv_from_zip('./spec/fixtures/import_establishments/zip_with_invalid_csv.zip')}.to raise_error(LoadError)
      end
    end

    describe '.import_establishments' do
      context 'with empty database' do
        before do
          File.open('./spec/fixtures/import_establishments/establishments_sample.csv') do |file|
            Establishment.import(file.read, -1)
          end
        end

        it 'converts integers' do
          expect(Establishment.find(100000).number_of_pupils).to eq(249)
        end

        it 'converts datetimes' do
          expect(Establishment.find(100000).last_changed_date).to eq(DateTime.parse('07-07-2025'))
        end

        it 'imports non-ascii characters' do
          expect(Establishment.find(100371).establishment_name).to eq('Ecole Française de Londres Jacques Prévert')
        end
      end

      context 'with existing records' do
        before do
          build(:establishment, id: 100000).save
          File.open('./spec/fixtures/import_establishments/establishments_sample.csv') do |file|
            Establishment.import(file.read, -1)
          end
        end

        it 'updates columns' do
          expect(Establishment.find(100000).number_of_pupils).to eq(249)
        end
      end
    end
  end
end
