require 'aws-sdk-s3'

module EnergySparks
  module S3Yaml
    def self.save(data, school_name, data_type:, bucket:, ext: 'yaml')
      client = Aws::S3::Client.new
      key = "#{data_type}-#{school_name.parameterize}.#{ext}"
      client.put_object(
        bucket: bucket,
        key: key,
        content_type: 'application/x-yaml',
        body: YAML.dump(data)
      )
    end

    def self.upload(filename, school_name, data_type:, bucket:, ext: 'marshal')
      client = Aws::S3::Client.new
      key = "#{data_type}-#{school_name.parameterize}.#{ext}"
      File.open(filename, 'rb') do |file|
        client.put_object(
          bucket: bucket,
          key: key,
          body: file
        )
      end
    end
  end
end
