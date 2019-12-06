require 'rails_helper'
require 'fileutils'

describe Amr::Importer do

  let(:thing_prefix) { 'this-path'}
  let(:config)      { AmrDataFeedConfig.new(identifier: thing_prefix ) }
  let(:bucket)      { 'test-bucket' }
  let(:thing_name)  { 'test-thing.csv' }
  let(:key)         { "#{thing_prefix}/#{thing_name}" }
  let(:object_data) {{ contents: [{ key: key , size: 100}, { key: "#{thing_prefix}" , size: 0}] }}
  let(:s3_client) {  Aws::S3::Client.new(stub_responses: true) }
  subject { Amr::Importer.new(config, bucket, s3_client) }

  before(:each) do
    s3_client.stub_responses(:list_objects, object_data)
  end

  it 'gets a list of everything in the bucket' do
    expect(subject.send(:get_array_of_files_in_bucket_with_prefix)).to eq [thing_name]
  end

  it 'gets a single item and puts in the folder' do
    bucket = { key => { body: 'meter-readings!' }}
    s3_client.stub_responses(:get_object, -> (context) {
      obj = bucket[context.params[:key]]
      obj || 'NoSuchKey'
    })

    FileUtils.mkdir_p config.local_bucket_path
    subject.send(:get_file_from_s3, thing_name)
    expect(File.read("#{config.local_bucket_path}/#{thing_name}")).to eq 'meter-readings!'
  end
end
