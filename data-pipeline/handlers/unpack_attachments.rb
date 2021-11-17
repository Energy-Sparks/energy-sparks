require 'aws-sdk-s3'
require 'mail'

module DataPipeline
  module Handlers
    class UnpackAttachments
      def initialize(client:, logger:, environment: {})
        @client = client
        @environment = environment
        @logger = logger
      end

      def process(key:, bucket:)
        email_file = @client.get_object(bucket: bucket, key: key)
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
      end

      def extract_download_links(_mail)
        return []
      end

      def download_csv_reports(_links)
        #OpenStruct.new(filename:, body:, mime_type:)
        return []
      end
    end
  end
end
