require 'aws-sdk-s3'

module EnergySparks
  module S3Yaml
    def self.save(data, school_name, data_type:, bucket:)
      client = Aws::S3::Client.new
      key = "#{data_type}-#{school_name.parameterize}.yaml"
      yaml = YAML.dump(data)
      client.put_object(
        bucket: bucket,
        key: key,
        content_type: 'application/x-yaml',
        body: yaml
      )
    end
  end
end
