require 'aws-sdk-s3'
require 'zip'

module DataPipeline
  module Handlers
    class UncompressFile

      def self.process(event:, context:)
        new(event: event, client: Aws::S3::Client.new, environment: ENV).process_file
      end

      def initialize(event:, client:, environment: {})
        @event = event
        @client = client
        @environment = environment
      end

      def uncompress_file
        s3_record = @event['Records'].first['s3']
        file_key = s3_record['object']['key']
        bucket_name = s3_record['bucket']['name']

        file = @client.get_object(bucket: bucket_name, key: file_key)
        prefix = file_key.split('/').first

        upload_responses = []
        begin
          Zip::File.open_buffer(file.body) do |zip_file|
            responses = zip_file.each do |entry|
              content = entry.get_input_stream.read
              upload_responses << @client.put_object(
                bucket: @environment['PROCESS_BUCKET'],
                key: "#{prefix}/#{entry.name}",
                body: content
              )
            end
          end
        rescue Zip::Error => e
          upload_responses << @client.put_object(
            bucket: @environment['UNPROCESSABLE_BUCKET'],
            key: file_key,
            body: file.body,
            content_type: file.content_type
          )
        end
        { statusCode: 200, body: JSON.generate(responses: upload_responses) }
      rescue => e
        { statusCode: 500, body: JSON.generate(e.message) }
      end
    end
  end
end
