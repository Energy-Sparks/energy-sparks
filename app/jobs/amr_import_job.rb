# frozen_string_literal: true

class AmrImportJob < ApplicationJob
  queue_as :regeneration

  def self.import_all(config, bucket)
    s3_client = Aws::S3::Client.new
    Rails.logger.info "Download all from S3 key pattern: #{config.identifier}"
    s3_client.list_objects_v2(bucket: bucket, prefix: "#{config.identifier}/").contents.each do |object|
      # need to ignore application/x-directory objects ending with /
      perform_later(config, bucket, object.key) unless object.key.end_with?('/')
    end
  end

  def perform(config, bucket, key)
    @s3_client = Aws::S3::Client.new
    @config = config
    @bucket = bucket
    file_path = get_file_from_s3(key)
    key_without_parent = key.partition('/').last
    Amr::CsvParserAndUpserter.perform(@config, file_path, key_without_parent)
    Rails.logger.info "Imported #{key}"
    archive_file(key, key_without_parent, file_path)
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: :amr_import_job, bucket: @bucket, config: @config.identifier, key:)
  end

  private

  def get_file_from_s3(key)
    Rails.logger.info "Downloading from S3 key: #{key}"
    response_target = "#{@config.local_bucket_path}/#{File.basename(key)}"
    @s3_client.get_object(bucket: @bucket, key:, response_target:)
    Rails.logger.info "Downloaded  from S3 key: #{key}"
    response_target
  end

  def archive_file(key, key_without_parent, file_path)
    archived_key = "#{@config.s3_archive_folder}/#{key_without_parent}"
    @s3_client.copy_object(bucket: @bucket, copy_source: "#{@bucket}/#{key}", key: archived_key)
    @s3_client.delete_object(bucket: @bucket, key:)
    File.delete(file_path)
    Rails.logger.info "Archived #{key} to #{archived_key} and removed local file"
  end
end
