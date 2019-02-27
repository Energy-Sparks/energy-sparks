require 'aws-sdk-s3'
require 'zip'

module DataPipeline
  module Handlers
    class UncompressFile

      def self.process(event:, context:)
        new(event: event, client: Aws::S3::Client.new, environment: ENV, logger: Logger.new(STDOUT)).uncompress_file
      end

      def initialize(event:, client:, logger:, environment: {})
        @event = event
        @client = client
        @environment = environment
        @logger = logger
      end

      def uncompress_file
        s3_record = @event['Records'].first['s3']
        file_key = s3_record['object']['key']
        bucket_name = s3_record['bucket']['name']

        @logger.info("Uncompressing: #{file_key} from: #{bucket_name}")

        file = @client.get_object(bucket: bucket_name, key: file_key)
        prefix = file_key.split('/').first

        upload_responses = []
        begin
          Zip::File.open_buffer(file.body) do |zip_file|
            responses = zip_file.each do |entry|
              content = entry.get_input_stream.read
              @logger.info("Uncompression successs moving: #{file_key} to: #{@environment['PROCESS_BUCKET']}")
              upload_responses << move_to_process_bucket("#{prefix}/#{entry.name}", content)
            end
          end
        rescue Zip::Error => e
          @logger.info("Uncompression failed moving: #{file_key} to: #{@environment['UNPROCESSABLE_BUCKET']}")
          upload_responses << move_to_unprocessable_bucket(file_key, file)
        end
        { statusCode: 200, body: JSON.generate(responses: upload_responses) }
      rescue => e
        { statusCode: 500, body: JSON.generate(e.message) }
      end

    private

      def move_to_process_bucket(key, content)
        @client.put_object(
          bucket: @environment['PROCESS_BUCKET'],
          key: key,
          body: content,
        )
      end

      def move_to_unprocessable_bucket(key, file)
        @client.put_object(
          bucket: @environment['UNPROCESSABLE_BUCKET'],
          key: key,
          body: file.body,
          content_type: file.content_type
        )
      end

    end
  end
end
