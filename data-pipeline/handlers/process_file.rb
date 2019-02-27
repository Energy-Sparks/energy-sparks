require 'aws-sdk-s3'

module DataPipeline
  module Handlers
    class ProcessFile

      def self.process(event:, context:)
        new(event: event, client: Aws::S3::Client.new, environment: ENV, logger: Logger.new(STDOUT)).process_file
      end

      def initialize(event:, client:, logger:, environment: {})
        @event = event
        @client = client
        @environment = environment
        @logger = logger
      end

      def process_file
        s3_record = @event['Records'].first['s3']
        file_key = s3_record['object']['key']
        bucket_name = s3_record['bucket']['name']

        @logger.info("Processing key: #{file_key} bucket_name: #{bucket_name}")

        file = @client.get_object(bucket: bucket_name, key: file_key)

        next_bucket = case file_key
        when /csv\Z/ then @environment['AMR_DATA_BUCKET']
        when /zip\Z/ then @environment['COMPRESSED_BUCKET']
        else @environment['UNPROCESSABLE_BUCKET']
        end

        response = @client.put_object(
          bucket: next_bucket,
          key: file_key,
          content_type: file.content_type,
          body: file.body
        )

        @logger.info("Moved: #{file_key} to: #{next_bucket}")

        { statusCode: 200, body: JSON.generate(response: response) }

      rescue => e
        { statusCode: 500, body: JSON.generate(e.message) }
      end
    end
  end
end
