require 'spec_helper'

require './handler'

describe DataPipeline::Handlers::ProcessFile do

  describe '#process' do

    let(:sheffield_csv)     { File.open('spec/support/files/sheffield_export.csv') }
    let(:sheffield_gas_csv) { File.open('spec/support/files/sheffield_export.csv') }
    let(:sheffield_zip)     { File.open('spec/support/files/sheffield_export.zip') }
    let(:unknown_file)      { File.open('spec/support/files/1x1.png') }

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
