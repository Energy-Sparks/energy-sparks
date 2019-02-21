require 'aws-sdk-s3'
require 'mail'

module DataPipeline
  module Handlers
    class UnpackAttachments

      def self.process(event:, context:)
        new(event: event, client: Aws::S3::Client.new, environment: ENV).unpack_attachments
      end

      def initialize(event:, client:, environment: {})
        @event = event
        @client = client
        @environment = environment
      end

      def unpack_attachments
        s3_record = @event['Records'].first['s3']
        file_key = s3_record['object']['key']
        bucket_name = s3_record['bucket']['name']

        email_file = @client.get_object(bucket: bucket_name, key: file_key)
        email = Mail.new(email_file.body.read)
        prefix = email.to.first.split('@').first

        responses = email.attachments.map do |attachment|
          @client.put_object(
            bucket: @environment['ATTACHMENT_BUCKET'],
            key: "#{prefix}/#{attachment.filename}",
            content_type: attachment.mime_type,
            body: attachment.decoded
          )
        end

        { statusCode: 200, body: JSON.generate(responses: responses) }

      rescue => e
        { statusCode: 500, body: JSON.generate(e.message) }
      end
    end
  end
end
