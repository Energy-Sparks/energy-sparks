# frozen_string_literal: true

module Amr
  class Importer
    def initialize(config, bucket: nil)
      @config = config
      @bucket = bucket || ENV.fetch('AWS_S3_AMR_DATA_FEEDS_BUCKET')
      @s3_client = Aws::S3::Client.new
    end

    def import_all
      Rails.logger.info "Download all from S3 key pattern: #{@config.identifier}"
      list_bucket_with_prefix.each do |filename|
        AmrImportJob.perform_later(@config, @bucket, filename)
      end
    end

    def import(filename)
      get_file_from_s3(filename)
      import_file(filename)
      archive_file(filename)
    rescue StandardError => e
      Rails.logger.error "Exception: running import for #{@config.description}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :import_all, config: @config.identifier, filename:)
    end

    private

    def s3_key(filename)
      "#{@config.identifier}/#{filename}"
    end

    def archived_key(filename)
      "#{@config.s3_archive_folder}/#{filename}"
    end

    def local_filename_and_path(filename)
      "#{@config.local_bucket_path}/#{filename}"
    end

    def get_file_from_s3(filename)
      key = s3_key(filename)
      Rails.logger.info "Downloading from S3 key: #{key}"
      @s3_client.get_object(bucket: @bucket, key:, response_target: local_filename_and_path(filename))
      Rails.logger.info "Downloaded  from S3 key: #{key}"
    end

    def list_bucket_with_prefix
      contents = @s3_client.list_objects(bucket: @bucket, prefix: "#{@config.identifier}/").contents
      # Folders come back with size 0 and we don't need those
      contents.reject(&:empty?).map { |record| File.basename(record.key) }
    end

    def import_file(filename)
      CsvParserAndUpserter.new(@config, filename).perform
      Rails.logger.info "Imported #{filename}"
    end

    def archive_file(filename)
      key = s3_key(filename)
      archived_key = archived_key(filename)
      @s3_client.copy_object(bucket: @bucket, copy_source: "#{@bucket}/#{key}", key: archived_key)
      @s3_client.delete_objects(bucket: @bucket, delete: { objects: [{ key: }] })
      File.delete local_filename_and_path(filename)
      Rails.logger.info "Archived #{key} to #{archived_key} and removed local file"
    end
  end
end
