RSpec.shared_examples_for 'a csvimportable' do |zipped_sample_path|
  it 'converts headers to snakecase correctly' do
    expect(described_class.convert_header('ColumnName (code)')).to eq('column_name_code')
  end

  describe '.read_csv_from_zip' do
    it 'finds data csv in zip file' do
      expect {described_class.read_csv_from_zip(zipped_sample_path)}.not_to raise_error
    end

    it 'throws error when no data csv is found' do
      expect {described_class.read_csv_from_zip('./spec/fixtures/csv_importable/zip_with_invalid_csv.zip')}.to raise_error(LoadError)
    end

    describe '.import_from_zip' do
      before do
        described_class.import_from_zip(zipped_sample_path, 1000)
      end

      it 'adds something to database' do
        expect(described_class.count).not_to eq(0)
      end
    end
  end
end
