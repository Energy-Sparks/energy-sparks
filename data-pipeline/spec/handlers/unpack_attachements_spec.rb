require 'spec_helper'

require './handlers/unpack_attachments'

describe DataPipeline::Handlers::UnpackAttachments do

  describe '#unpack_attachments' do

    let(:sheffield_email) { File.open('spec/support/emails/sheffield_email.txt') }
    let(:sheffield_email_no_attachment) { File.open('spec/support/emails/sheffield_email_no_attachments.txt') }
    let(:client) { Aws::S3::Client.new(stub_responses: true) }
    let(:environment) { {'PROCESS_BUCKET' => 'test-bucket' } }

    before do
      client.stub_responses(
        :get_object, ->(context) {
          case context.params[:key]
          when 'sheffield-email.txt'
            { body: sheffield_email}
          when 'sheffield-email-no-attachment.txt'
            { body: sheffield_email_no_attachment}
          else
            'NotFound'
          end
        }
      )
    end

    describe 'when the email has an attachment' do

      let(:event){ DataPipeline::Support::Events.sheffield_email_added }

      it 'puts the attachment file in the PROCESS_BUCKET from the environment using the prefix the email was sent to' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/4003063_9232_Export_20181108_120524_290.zip')
        expect(request[:params][:bucket]).to eq('test-bucket')
        expect(request[:params][:content_type]).to eq('application/zip')
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments
        expect(response[:statusCode]).to eq(200)
      end

      it 'returns the code of the files created' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments
        body = JSON.parse(response[:body])
        expect(body['responses'].size).to eq(1)
      end

    end

    describe 'when the email has no attachments' do

      let(:event){ DataPipeline::Support::Events.sheffield_email_added_no_attachment }

      it 'does not add any files' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments

        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:get_object)
      end

      it 'returns a success code' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments
        expect(response[:statusCode]).to eq(200)
      end

      it 'returns the code of the files created' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments
        body = JSON.parse(response[:body])
        expect(body['responses']).to be_empty
      end
    end

    describe 'when the file cannot be found' do

      let(:event){ DataPipeline::Support::Events.missing_file }

      it 'returns an error code' do
        response = DataPipeline::Handlers::UnpackAttachments.new(event: event, client: client, environment: environment).unpack_attachments
        body = JSON.parse(response[:body])
        expect(response[:statusCode]).to eq(500)
      end
    end

  end

end
