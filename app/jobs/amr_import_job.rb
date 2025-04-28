# frozen_string_literal: true

class AmrImportJob < ApplicationJob
  queue_as :regeneration

  include GoodJob::ActiveJobExtensions::Concurrency
  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { "#{self.class.name}-#{arguments.first.identifier}" } # AmrImportJob-config.idenitifier
  )

  def self.import_all(config, bucket)
    s3_client = Aws::S3::Client.new
    Rails.logger.info "Download all from S3 key pattern: #{config.identifier}"
    s3_client.list_objects_v2(bucket: bucket, prefix: "#{config.identifier}/").contents.each do |object|
      # need to ignore application/x-directory objects ending with /
      perform_later(config, bucket, object.key) unless object.key.end_with?('/')
    end
  end

  def perform(config, bucket, key)
    s3_client = Aws::S3::Client.new
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

  private

  def archive_file(s3_client, config, bucket, key, key_without_parent)
    archived_key = "#{config.s3_archive_folder}/#{key_without_parent}"
    s3_client.copy_object(bucket:, copy_source: "#{bucket}/#{key}", key: archived_key)
    s3_client.delete_object(bucket:, key:)
    Rails.logger.info "Archived #{key} to #{archived_key} and removed local file"
  end
end
