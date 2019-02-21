require 'spec_helper'

require './handlers/process_file'

describe DataPipeline::Handlers::ProcessFile do

  describe '#process_file' do

    let(:sheffield_csv) { File.open('spec/support/files/sheffield_export.csv') }
    let(:sheffield_zip) { File.open('spec/support/files/sheffield_export.zip') }
    let(:unknown_file) { File.open('spec/support/files/1x1.png') }

    let(:client) { Aws::S3::Client.new(stub_responses: true) }
    let(:environment) {
      {
        'AMR_DATA_BUCKET' => 'data-bucket',
        'COMPRESSED_BUCKET' => 'compressed-bucket',
        'UNPROCESSABLE_BUCKET' => 'unprocessable-bucket'
      }
    }

    before do
      client.stub_responses(
        :get_object, ->(context) {
          case context.params[:key]
          when 'sheffield/export.csv'
            { body: sheffield_csv}
          when 'sheffield/export.zip'
            { body: sheffield_zip}
          when 'sheffield/image.png'
            { body: unknown_file}
          else
            'NotFound'
          end
        }
      )
    end

    describe 'when the file is a CSV' do

      let(:event){ DataPipeline::Support::Events.csv_added }

      it 'puts the attachment file in the AMR_DATA_BUCKET from the environment using the key of the object added' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/export.csv')
        expect(request[:params][:bucket]).to eq('data-bucket')
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file
        expect(response[:statusCode]).to eq(200)
      end

    end

    describe 'when the file is a zip' do

      let(:event){ DataPipeline::Support::Events.zip_added }

      it 'puts the attachment file in the COMPRESSED_BUCKET from the environment using the key of the object added' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/export.zip')
        expect(request[:params][:bucket]).to eq('compressed-bucket')
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file
        expect(response[:statusCode]).to eq(200)
      end

    end

    describe 'when the file is an image' do

      let(:event){ DataPipeline::Support::Events.image_added }

      it 'puts the attachment file in the UNPROCESSABLE_BUCKET from the environment using the key of the object added' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/image.png')
        expect(request[:params][:bucket]).to eq('unprocessable-bucket')
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file
        expect(response[:statusCode]).to eq(200)
      end

    end

    describe 'when the file cannot be found' do

      let(:event){ DataPipeline::Support::Events.missing_file }

      it 'returns an error code' do
        response = DataPipeline::Handlers::ProcessFile.new(event: event, client: client, environment: environment).process_file
        expect(response[:statusCode]).to eq(500)
      end
    end

  end

end
