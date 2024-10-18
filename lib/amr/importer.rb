# frozen_string_literal: true

module Amr
  class Importer
    def initialize(config, bucket)
      @config = config
      @bucket = bucket
      @s3_client = Aws::S3::Client.new
    end

    def import_all
      Rails.logger.info "Download all from S3 key pattern: #{@config.identifier}"
      @s3_client.list_objects_v2(bucket: @bucket, prefix: @config.identifier, delimiter: '/').contents.each do |object|
        AmrImportJob.perform_later(@config, @bucket, object.key)
      end
    end

    def import(key)
      filename = File.basename(key)
      get_file_from_s3(key, filename)
      CsvParserAndUpserter.new(@config, filename).perform
      Rails.logger.info "Imported #{filename}"
      archive_file(key, filename)
    rescue StandardError => e
      Rails.logger.error "Exception: running import for #{@config.description}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :import_all, config: @config.identifier, key:)
    end

    private

    def local_filename_and_path(filename)
      "#{@config.local_bucket_path}/#{filename}"
    end

    def get_file_from_s3(key, filename)
      Rails.logger.info "Downloading from S3 key: #{key}"
      @s3_client.get_object(bucket: @bucket, key:, response_target: local_filename_and_path(filename))
      Rails.logger.info "Downloaded  from S3 key: #{key}"
    end

    def archive_file(key, filename)
      archived_key = "#{@config.s3_archive_folder}/#{filename}"
      @s3_client.copy_object(bucket: @bucket, copy_source: key, key: archived_key)
      @s3_client.delete_objects(bucket: @bucket, delete: { objects: [{ key: }] })
      File.delete(local_filename_and_path(filename))
      Rails.logger.info "Archived #{key} to #{archived_key} and removed local file"
    end
  end
end
