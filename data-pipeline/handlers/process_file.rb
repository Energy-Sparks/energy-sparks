require 'aws-sdk-s3'

module DataPipeline
  module Handlers
    class ProcessFile
      def initialize(client:, logger:, environment: {})
        @client = client
        @environment = environment
        @logger = logger
      end

      def process(key:, bucket:)
        file = @client.get_object(bucket: bucket, key: key)

        next_bucket = case key
                      when /csv\Z/ then @environment['AMR_DATA_BUCKET']
                      when /zip\Z/ then @environment['COMPRESSED_BUCKET']
                      else @environment['UNPROCESSABLE_BUCKET']
                      end

        response = @client.put_object(
          bucket: next_bucket,
          key: key,
          content_type: file.content_type,
          body: file.body
        )

        @logger.info("Moved: #{key} to: #{next_bucket}")

        { statusCode: 200, body: JSON.generate(response: response) }
      end
    end
  end
end
