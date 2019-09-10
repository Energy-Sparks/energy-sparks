require 'spec_helper'

require './handler'

describe DataPipeline::Handlers::ProcessFile do

  describe '#process' do

    let(:sheffield_csv)       { File.open('spec/support/files/sheffield_export.csv') }
    let(:cr_csv)              { File.open('spec/support/files/cr.csv') }
    let(:cr_empty_lines_csv)  { File.open('spec/support/files/cr_empty_lines.csv') }
    let(:highlands_csv)       { File.open('spec/support/files/highlands.csv') }
    let(:highlands_invalid_character_csv)       { File.open('spec/support/files/highlands-invalid-character.csv', "r:UTF-8") }
    let(:sheffield_gas_csv)   { File.open('spec/support/files/sheffield_export.csv') }
    let(:sheffield_zip)       { File.open('spec/support/files/sheffield_export.zip') }
    let(:unknown_file)        { File.open('spec/support/files/1x1.png') }
    let(:logger) { Logger.new(IO::NULL) }
    let(:client) { Aws::S3::Client.new(stub_responses: true) }
    let(:environment) {
      {
        'AMR_DATA_BUCKET' => 'data-bucket',
        'COMPRESSED_BUCKET' => 'compressed-bucket',
        'UNPROCESSABLE_BUCKET' => 'unprocessable-bucket'
      }
    }

    let(:handler){ DataPipeline::Handlers::ProcessFile }
    let(:response){ DataPipeline::Handler.run(handler: handler, event: event, client: client, environment: environment, logger: logger) }

    before do
      client.stub_responses(
        :get_object, ->(context) {
          case context.params[:key]
          when 'sheffield/export.csv'
            { body: sheffield_csv }
          when 'sheffield/cr.csv'
            { body: cr_csv }
          when 'cr_empty_lines.csv'
            { body: cr_empty_lines_csv }
          when 'highlands-invalid-character.csv'
            { body: highlands_invalid_character_csv }
          when 'highlands.csv'
            { body: highlands_csv }
          when 'sheffield/export.zip'
            { body: sheffield_zip }
          when 'sheffield/image.png'
            { body: unknown_file }
          when  'sheffield-gas/Sheffield City Council - Energy Sparks (Daily Email)20190303.csv'
            { body: sheffield_gas_csv }
          else
            'NotFound'
          end
        }
      )
      response
    end

    describe 'when the file is a sheffield gas CSV with spaces in the filename' do

      let(:event){ DataPipeline::Support::Events.csv_sheffield_gas_added }

      it 'puts the attachment file in the AMR_DATA_BUCKET from the environment using the key of the object added' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield-gas/Sheffield City Council - Energy Sparks (Daily Email)20190303.csv')
        expect(request[:params][:bucket]).to eq('data-bucket')
      end

      it 'returns a success code' do
        expect(response[:statusCode]).to eq(200)
      end
    end

    describe 'when the file is a CSV' do

      let(:event){ DataPipeline::Support::Events.csv_added }

      it 'puts the attachment file in the AMR_DATA_BUCKET from the environment using the key of the object added' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/export.csv')
        expect(request[:params][:bucket]).to eq('data-bucket')

      end

      it 'returns a success code' do
        expect(response[:statusCode]).to eq(200)
      end

      context 'when the file has mixed line endings' do

        let(:event){ DataPipeline::Support::Events.cr_csv_added }

        it 'normalises them' do
          request = client.api_requests.last
          expect(request[:params][:body].readlines.all?{|line| line.match?(/[^\r]\n\Z/)}).to eq(true)
        end
      end

      context 'when the file has empty lines' do

        let(:event){ DataPipeline::Support::Events.cr_empty_lines_csv_added }

        it 'removes them' do
          request = client.api_requests.last

          expect(request[:params][:body].readlines.any?{|line| line.match?(/^$/)}).to eq(false)
        end
      end

      context 'when the file has nulls and empty lines' do

        let(:event){ DataPipeline::Support::Events.highlands_csv_added }

        it 'removes them' do
          request = client.api_requests.last

          expect(request[:params][:body].readlines.any?{|line| line.match?(/\u0000/)}).to eq(false)
          request[:params][:body].rewind
          expect(request[:params][:body].readlines.any?{|line| line.match?(/^$/)}).to eq(false)
        end
      end

        context 'when the file has nulls and empty lines and invalid characters' do

        let(:event){ DataPipeline::Support::Events.highlands_invalid_character_csv_added }

        it 'removes them' do
          request = client.api_requests.last

          expect(request[:params][:body].readlines.any?{|line| line.match?(/\u0000/)}).to eq(false)
          request[:params][:body].rewind
          expect(request[:params][:body].readlines.any?{|line| line.match?(/^$/)}).to eq(false)
        end
      end

    end

    describe 'when the file is a zip' do

      let(:event){ DataPipeline::Support::Events.zip_added }

      it 'puts the attachment file in the COMPRESSED_BUCKET from the environment using the key of the object added' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/export.zip')
        expect(request[:params][:bucket]).to eq('compressed-bucket')
      end

      it 'returns a success code' do
        expect(response[:statusCode]).to eq(200)
      end

    end

    describe 'when the file is an image' do

      let(:event){ DataPipeline::Support::Events.image_added }

      it 'puts the attachment file in the UNPROCESSABLE_BUCKET from the environment using the key of the object added' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/image.png')
        expect(request[:params][:bucket]).to eq('unprocessable-bucket')
      end

      it 'returns a success code' do
        expect(response[:statusCode]).to eq(200)
      end

    end

  end

end
