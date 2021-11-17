module DataPipeline
  module Support
    class Events

      def self.file_event(filename:, bucket:)
        {
          "Records" => [
            {
              "eventVersion" => "2.0",
              "eventTime" => "1970-01-01T00:00:00.000Z",
              "requestParameters" => {
                "sourceIPAddress" => "127.0.0.1"
              },
              "s3" => {
                "configurationId" => "testConfigRule",
                "object" => {
                  "eTag" => "0123456789abcdef0123456789abcdef",
                  "sequencer" => "0A1B2C3D4E5F678901",
                  "key" => filename,
                  "size" => 1024
                },
                "bucket" => {
                  "arn" => '123',
                  "name" => bucket,
                  "ownerIdentity" => {
                    "principalId" => "EXAMPLE"
                  }
                },
                "s3SchemaVersion" => "1.0"
              },
              "responseElements" => {
                "x-amz-id-2" => "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH",
                "x-amz-request-id" => "EXAMPLE123456789"
              },
              "awsRegion" => "us-east-1",
              "eventName" => "ObjectCreated:Put",
              "userIdentity" => {
                "principalId" => "EXAMPLE"
              },
              "eventSource" => "aws:s3"
            }
          ]
        }
      end

      def self.sheffield_email_added
        file_event(filename: 'sheffield-email.txt', bucket: 'email-bucket')
      end

      def self.sheffield_email_forwarded
        file_event(filename: 'sheffield-fwd.txt', bucket: 'email-bucket')
      end

      def self.sheffield_email_added_no_attachment
        file_event(filename: 'sheffield-email-no-attachment.txt', bucket: 'email-bucket')
      end

      def self.imserv_email_with_link_added
        file_event(filename: 'imserv_email_with_link.txt', bucket: 'email-bucket')
      end

      def self.csv_added
        file_event(filename: 'sheffield/export.csv', bucket: 'file-bucket')
      end

      def self.cr_csv_added
        file_event(filename: 'sheffield/cr.csv', bucket: 'file-bucket')
      end

      def self.cr_empty_lines_csv_added
        file_event(filename: 'cr_empty_lines.csv', bucket: 'file-bucket')
      end

      def self.highlands_csv_added
        file_event(filename: 'highlands.csv', bucket: 'file-bucket')
      end

       def self.highlands_invalid_character_csv_added
        file_event(filename: 'highlands-invalid-character.csv', bucket: 'file-bucket')
      end

      def self.csv_sheffield_gas_added
        file_event(filename: 'sheffield-gas/Sheffield+City+Council+-+Energy+Sparks+%28Daily+Email%2920190303.csv', bucket: 'file-bucket')
      end

      def self.zip_added
        file_event(filename: 'sheffield/export.zip', bucket: 'file-bucket')
      end

      def self.image_added
        file_event(filename: 'sheffield/image.png', bucket: 'file-bucket')
      end

      def self.missing_file
        file_event(filename: 'missing.txt', bucket: 'email-bucket')
      end

    end
  end
end
