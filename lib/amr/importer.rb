module Amr
  class Importer
    def initialize(config, bucket = nil, s3_client = nil)
      @config = config
      @bucket = bucket || ENV['AWS_S3_AMR_DATA_FEEDS_BUCKET']
      @s3_client = s3_client || Aws::S3::Client.new
    end

    def import_all
      Rails.logger.info "Download all from S3 key pattern: #{@config.identifier}"
      get_array_of_files_in_bucket_with_prefix.each do |file_name|
        get_file_from_s3(file_name)
        import_file(file_name)
        archive_file(file_name)
      end
      Rails.logger.info "Downloaded all"
    end

  private

    def get_file_from_s3(file_name)
      key = "#{@config.identifier}/#{file_name}"
      file_name_and_path = "#{@config.local_bucket_path}/#{file_name}"
      Rails.logger.info "Downloading from S3 key: #{key}"
      @s3_client.get_object(bucket: @bucket, key: key, response_target: file_name_and_path)
      Rails.logger.info "Downloaded  from S3 key: #{key}"
    end

    def get_array_of_files_in_bucket_with_prefix
      contents = @s3_client.list_objects(bucket: @bucket, prefix: "#{@config.identifier}/").contents
      # Folders come back with size 0 and we don't need those
      contents.select { |record| !record.size.zero? }.map { |record| File.basename(record.key) }
    end

    def import_file(file_name)
      importer = CsvParserAndUpserter.new(@config, file_name)
      importer.perform
      Rails.logger.info "Imported #{file_name}"
    end

    def archive_file(file_name)
      key = "#{@config.identifier}/#{file_name}"
      archived_key = "#{@config.s3_archive_folder}/#{file_name}"
      pp "Archiving #{key} to #{archived_key}"
      @s3_client.copy_object(bucket: @bucket, copy_source: "#{@bucket}/#{key}", key: archived_key)

      @s3_client.delete_objects(bucket: @bucket, delete: { objects: [{ key: key }] })
      Rails.logger.info "Archived #{key} to #{archived_key}"
    end
  end
end
