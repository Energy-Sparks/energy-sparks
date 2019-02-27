require 'aws-sdk-s3'
require 'mail'

module DataPipeline
  module Handlers
    class UnpackAttachments
      def self.process(event:, context:)
        new(
          event: event,
          client: Aws::S3::Client.new,
          environment: ENV,
          logger: Logger.new(STDOUT),
          context: context
        ).unpack_attachments
      end

      def initialize(event:, client:, logger:, environment: {}, context: {})
        @event = event
        @client = client
        @environment = environment
        @logger = logger
        @context = context
      end

      def unpack_attachments
        s3_record = @event['Records'].first['s3']
        file_key = s3_record['object']['key']
        bucket_name = s3_record['bucket']['name']

        @logger.info("Unpacking attachments key: #{file_key} from: #{bucket_name}")

        email_file = @client.get_object(bucket: bucket_name, key: file_key)
        email = Mail.new(email_file.body.read)

        sent_to = email.header['X-Forwarded-To'] || email.to.first
        @logger.info("Receipt address: #{sent_to}")

        prefix = sent_to.to_s.split('@').first

        @logger.info("Prefix: #{prefix}")


        responses = email.attachments.map do |attachment|
          @logger.info("Moving: #{attachment.filename} to: #{@environment['PROCESS_BUCKET']}")
          @client.put_object(
            bucket: @environment['PROCESS_BUCKET'],
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
