module Amr
  class Importer
    AWS_REGION = 'eu-west-2'.freeze

    def initialize(config)
      @config = config
      @bucket = ENV['AWS_S3_AMR_DATA_FEEDS_BUCKET']
      @s3_client = Aws::S3::Client.new(region: AWS_REGION)
    end

    def import_all
      Rails.logger.info "Download all from S3 key pattern: #{@config.s3_folder}"
      get_array_of_files_in_bucket_with_prefix.each do |key|
        get_file_from_s3(key)
        import_file(key)
      end
      Rails.logger.info "Downloaded all"
    end

  private

    def get_file_from_s3(file_name)
      key = "#{@config.s3_folder}/#{file_name}"
      file_name_and_path = "#{@config.local_bucket_path}/#{file_name}"
      Rails.logger.info "Downloading from S3 key: #{key}"
      @s3_client.get_object(bucket: @bucket, key: key, response_target: file_name_and_path)
      Rails.logger.info "Downloaded  from S3 key: #{key}"
    end

    def get_array_of_files_in_bucket_with_prefix
      contents = @s3_client.list_objects(bucket: @bucket, prefix: @config.s3_folder).contents
      # Folders come back with size 0 and we don't need those
      contents.select { |record| !record.empty? }.map { |record| File.basename(record.key) }
    end

    def import_file(file_name)
      importer = CsvImporter.new(@config, file_name)
      importer.parse
      Rails.logger.info "Imported #{file_name}"
    end
  end
end
