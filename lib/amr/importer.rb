module Amr
  class Importer
    def initialize(readings_date, config, file_name)
      @file_name_and_path = "#{config.local_bucket_path}/#{file_name}"
      @file_name = file_name
      @config = config
      @readings_date = readings_date
    end

    def import
      get_file_from_s3
      if Pathname.new(@file_name_and_path).exist?
        we_have_a_file_so_import
      else
        puts "Missing file, not local or in S3 #{file}"
      end
    end

    def get_file_from_s3
      puts "Download from S3 #{@file_name}"
      region = 'eu-west-2'
      bucket = ENV['AWS_S3_AMR_DATA_FEEDS_BUCKET']
      key = "#{@config.s3_folder}/#{@file_name}"
      s3 = Aws::S3::Client.new(region: region)
      puts key
      s3.get_object(bucket: bucket, key: key, response_target: @file_name_and_path)
      puts "Downloaded"
    end

    def we_have_a_file_so_import
      importer = CsvImporter.new(@config, @file_name)
      importer.parse
      puts "Imported"
    end
  end
end
