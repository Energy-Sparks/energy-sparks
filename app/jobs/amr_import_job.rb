# frozen_string_literal: true

class AmrImportJob < ApplicationJob
  queue_as :regeneration

  # initially this import was sequential in the rake task
  # it was then changed to create a job for each file
  # now changing to a job for each config to lower database load
  def self.import_all(config)
    bucket = ENV.fetch('AWS_S3_AMR_DATA_FEEDS_BUCKET')
    s3_client = Aws::S3::Client.new
    Rails.logger.info "Download all from S3 key pattern: #{config.identifier}"
    objects = s3_client.list_objects_v2(bucket:, prefix: "#{config.identifier}/").contents
                       # seeing application/x-directory objects ending with /
                       .reject { |object| object.key.end_with?('/') }
    perform_later(config, bucket, objects.map(&:key)) unless objects.empty?
  end

  def perform(config, bucket, keys)
    s3_client = Aws::S3::Client.new
    keys.each { |key| process_key(s3_client, config, bucket, key) }
  end

  private

  def process_key(s3_client, config, bucket, key)
    Tempfile.create([File.basename(key, File.extname(key)), File.extname(key)]) do |tempfile|
      Rails.logger.info "Downloading s3://#{bucket}/#{key}"
      s3_client.get_object(bucket:, key:, response_target: tempfile.path)
      key_without_parent = key.partition('/').last
      Amr::CsvParserAndUpserter.perform(config, tempfile.path, key_without_parent)
      Rails.logger.info "Imported #{key}"
      archive_file(s3_client, config, bucket, key, key_without_parent)
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: :amr_import_job, bucket:, config: config.identifier, key:)
  end

  def archive_file(s3_client, config, bucket, key, key_without_parent)
    archived_key = "#{config.s3_archive_folder}/#{key_without_parent}"
    s3_client.copy_object(bucket:, copy_source: Rack::Utils.escape_path("#{bucket}/#{key}"), key: archived_key)
    s3_client.delete_object(bucket:, key:)
    Rails.logger.info "Archived #{key} to #{archived_key} and removed local file"
  end
end
