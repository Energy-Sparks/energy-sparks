require 'aws-sdk-s3'
require 'mail'
require 'faraday'
require 'rollbar'

module DataPipeline
  module Handlers
    class UnpackAttachments
      IMSERV_LINK_REGEX = %r{(https\://datavision.imserv.com/imgserver/InternalImage.aspx\?[a-zA-Z0-9&%=]+)}.freeze

      def initialize(client:, logger:, environment: {})
        @client = client
        @environment = environment
        @logger = logger
        Rollbar.configure do |config|
          config.access_token = @environment["ROLLBAR_ACCESS_TOKEN"]
          config.environment = "data-pipeline"
        end
      end

      def process(key:, bucket:)
        email_file = @client.get_object(bucket: bucket, key: key)
        email = Mail.new(email_file.body.read)

        sent_to = email.header['X-Forwarded-To'] || email.to.first
        @logger.info("Receipt address: #{sent_to}")

        prefix = sent_to.to_s.split('@').first

        @logger.info("Prefix: #{prefix}")

        if email.attachments.any?
          responses = store_attachments(prefix, email)
        else
          responses = store_downloads(prefix, email)
        end
        { statusCode: 200, body: JSON.generate(responses: responses) }
      end

      def store_attachments(prefix, email)
        responses = email.attachments.map do |attachment|
          @logger.info("Moving: #{attachment.filename} to: #{@environment['PROCESS_BUCKET']}")
          @client.put_object(
            bucket: @environment['PROCESS_BUCKET'],
            key: "#{prefix}/#{attachment.filename}",
            content_type: attachment.mime_type,
            body: attachment.decoded
          )
        end
        responses
      end

      def store_downloads(prefix, email)
        @logger.info("Extracting download links")
        links = extract_download_links(email, prefix)
        results = download_csv_reports(links, prefix)
        responses = results.map do |download|
          @logger.info("Storing: #{download.filename} to: #{@environment['PROCESS_BUCKET']}")
          @client.put_object(
            bucket: @environment['PROCESS_BUCKET'],
            key: "#{prefix}/#{download.filename}",
            content_type: download.mime_type,
            body: download.body
          )
        end
        responses
      end

      def extract_download_links(mail, prefix = nil)
        begin
          if mail.parts.any?
            to_match = mail.parts.first.decoded
          else
            to_match = mail.decoded
          end
          to_match.scan(IMSERV_LINK_REGEX).flatten
        rescue => e
          @logger.error("Unable to process mail body: #{mail.subject}, #{e.message}")
          @logger.error(e.backtrace)
          Rollbar.error(e, subject: mail.subject, prefix: prefix)
          []
        end
      end

      def download_csv_reports(links, prefix = nil)
        results = []
        links.each do |link|
          begin
            @logger.info("Downloading: #{link}")
            resp = Faraday.get(link)
            if download_error?(resp)
              @logger.error("Unable to download file #{link}")
              Rollbar.error("Unable to download file", link: link, prefix: prefix)
            else
              results << OpenStruct.new(filename: filename(resp, link), body: resp.body, mime_type: resp.headers["content-type"])
            end
          rescue => e
            @logger.error("Unable to download file #{link}, #{e.message}")
            @logger.error(e.backtrace)
            Rollbar.error(e, link: link, prefix: prefix)
          end
        end
        results
      end

      private

      def download_error?(resp)
        #they only use 200 errors, but check anyway status anyway
        #not found errors are returned with an error message and an HTML content type
        #check for both in case either change
        !resp.success? || (resp.headers["content-type"] && resp.headers["content-type"].include?("text/html")) || resp.body.match("Your image cannot be displayed at this time")
      end

      def filename(resp, link)
        if resp.headers["content-disposition"] && resp.headers["content-disposition"].match(/filename=(\"?)(.+)\1/)
          resp.headers["content-disposition"].match(/filename=(\"?)(.+)\1/)[2]
        else
          link.gsub(%r{(:|/|\?)}, "_")
        end
      end
    end
  end
end
