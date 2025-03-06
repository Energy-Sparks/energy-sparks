require 'rails_helper'
require 'fileutils'

describe Amr::DataFileParser, type: :service do
  let!(:config) { create(:amr_data_feed_config) }
  let(:path_and_file_name) { 'spec/fixtures/amr_upload_data_files/' + file_name }

  let(:parser) { Amr::DataFileParser.new(config, path_and_file_name)}
  let(:parsed_lines) { parser.perform }

  context 'with standard csv file' do
    let(:file_name) { 'example-sheffield-file.csv' }

    it 'parses the file' do
      expect(parsed_lines.length).to eq 3
    end
  end

  context 'with csv with carriage return as line ending' do
    let(:file_name) { 'with-carriage-return-line-endings.csv' }

    it 'parses the file' do
      expect(parsed_lines.length).to eq 13
    end
  end

  context 'when a file needs cleaning' do
    ['with-carriage-return-line-endings.csv',
     'with-mixed-line-endings.csv',
     'with-nulls-and-empty-lines.csv',
     'with-nulls-empty-lines-invalid-chars.csv'].each do |file|
       context file do
         let(:file_name) { file }

         it 'parses the file' do
           expect(parsed_lines.length).not_to eq 0
         end
       end
     end
  end

  context 'with invalid file' do
    ['not_a_csv.csv', 'not_a_xlsx.xlsx'].each do |file|
      context file do
        let(:file_name) { file }

        it 'raises error' do
          expect { parsed_lines }.to raise_error(StandardError)
        end
      end
    end

    context 'and its an energy assets file' do
      let!(:config) { create(:amr_data_feed_config, identifier: 'energy-assets2') }

      context 'when its an illegal quoting error' do
        let(:file_name) { 'energy_assets_invalid.csv' }

        it 'does not raise an error' do
          expect(parsed_lines).to be_empty
        end
      end

      context 'when its some other error' do
        ['not_a_csv.csv', 'not_a_xlsx.xlsx'].each do |file|
          context file do
            let(:file_name) { file }

            it 'raises error' do
              expect { parsed_lines }.to raise_error(StandardError)
            end
          end
        end
      end
    end
  end

  context 'xlsx conversion to csv' do
    let(:file_name) { 'date-test.xlsx' }

    it 'exports dates and datetimes to ISO 8601 format' do
      parsed_lines[1..].each do |row|
        expect(row[2]).to eql(row[3])
      end
    end
  end
end
