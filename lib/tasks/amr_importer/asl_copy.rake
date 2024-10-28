# frozen_string_literal: true

namespace :amr do
  desc 'Import data from csv'
  task asl_copy: :environment do
    uri = URI(ENV.fetch('ASL_SFTP_URI'))
    bucket = ENV.fetch('AWS_S3_AMR_DATA_FEEDS_BUCKET')
    s3 = Aws::S3::Client.new
    key = s3.get_object(bucket:, key: 'asl_holdings_ftp_key.pem').body.read
    config = AmrDataFeedConfig.find_by(identifier: 'asl-centrica-solar')
    Net::SFTP.start(uri.host, uri.user, port: uri.port, key_data: [key], passphrase: ENV.fetch('ASL_SFTP_PASSPHRASE'),
                                        logger: Rails.logger, non_interactive: true) do |sftp|
      sftp.dir.glob(uri.path, '*.csv').sort_by { |e| e.attributes.mtime }.reverse_each do |entry|
        puts entry.name
        break if AmrDataFeedImportLog.exists?(amr_data_feed_config_id: config.id, file_name: entry.name)

        data = sftp.download!(File.join(uri.path, entry.name))
        s3.put_object(bucket:, key: File.join(config.identifier, entry.name), body: data)
      end
    end
  rescue StandardError => e
    Rollbar.error(e, job: :asl_copy, bucket:, config: config.identifier)
    raise
  end
end
