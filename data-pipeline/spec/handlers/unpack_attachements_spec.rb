require 'spec_helper'

require './handler'

describe DataPipeline::Handlers::UnpackAttachments do

  describe '#process' do

    let(:sheffield_email) { File.open('spec/support/emails/sheffield_email.txt') }
    let(:sheffield_email_fwd) { File.open('spec/support/emails/sheffield-fwd.txt') }
    let(:sheffield_email_no_attachment) { File.open('spec/support/emails/sheffield_email_no_attachments.txt') }

    let(:logger){ Logger.new(IO::NULL) }
    let(:client) { Aws::S3::Client.new(stub_responses: true) }
    let(:environment) { {'PROCESS_BUCKET' => 'test-bucket' } }

    let(:handler){ DataPipeline::Handlers::UnpackAttachments }
    let(:response){ DataPipeline::Handler.run(handler: handler, event: event, client: client, environment: environment, logger: logger) }

    before do
      client.stub_responses(
        :get_object, ->(context) {
          case context.params[:key]
          when 'sheffield-email.txt'
            { body: sheffield_email}
          when 'sheffield-fwd.txt'
            { body: sheffield_email_fwd}
          when 'sheffield-email-no-attachment.txt'
            { body: sheffield_email_no_attachment}
          else
            'NotFound'
          end
        }
      )
      response
    end

    describe 'when the email has an attachment' do

      let(:event){ DataPipeline::Support::Events.sheffield_email_added }

      it 'puts the attachment file in the PROCESS_BUCKET from the environment using the prefix the email was sent to' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/4003063_9232_Export_20181108_120524_290.zip')
        expect(request[:params][:bucket]).to eq('test-bucket')
        expect(request[:params][:content_type]).to eq('application/zip')
      end

      it 'returns a success code' do
        expect(response[:statusCode]).to eq(200)
      end

      it 'returns the code of the files created' do
        body = JSON.parse(response[:body])
        expect(body['responses'].size).to eq(1)
      end

    end

    describe 'when the email has been forwarded' do

      let(:event){ DataPipeline::Support::Events.sheffield_email_forwarded }

      it 'uses the forwarded to header instead of the to field' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:put_object)
        expect(request[:params][:key]).to eq('sheffield/4003063_9232_Export_20190227_120407_366.zip')
      end

    end

    describe 'when the email has no attachments' do

      let(:event){ DataPipeline::Support::Events.sheffield_email_added_no_attachment }

      it 'does not add any files' do
        request = client.api_requests.last
        expect(request[:operation_name]).to eq(:get_object)
      end

      it 'returns a success code' do
        expect(response[:statusCode]).to eq(200)
      end

      it 'returns the code of the files created' do
        body = JSON.parse(response[:body])
        expect(body['responses']).to be_empty
      end
    end

  end

end
