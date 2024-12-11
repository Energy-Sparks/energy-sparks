module S3Helper
  def s3_csv_download_url(identifier, file_name)
    signer = Aws::S3::Presigner.new
    url, = signer.presigned_request(
      :get_object, bucket: ENV.fetch('AWS_S3_AMR_DATA_FEEDS_BUCKET'), key: "archive-#{identifier}/#{file_name}"
    )
    url
  end
end
