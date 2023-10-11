require 'rails_helper'
require 'fileutils'

describe Amr::Importer do
  subject { Amr::Importer.new(config, bucket, s3_client) }

  let(:bucket)        { 'test-bucket' }
  let(:thing_prefix)  { 'this-path' }
  let(:thing_name)    { 'test-thing.csv' }
  let(:key)           { "#{thing_prefix}/#{thing_name}" }

  let(:config)        { create(:amr_data_feed_config, identifier: thing_prefix) }

  let(:expected_local_file) { "#{config.local_bucket_path}/#{thing_name}" }

  let(:s3_client) { Aws::S3::Client.new(stub_responses: true) }

  # responses from AWS API to stub out network calls in client
  let(:list_of_objects) { { contents: [{ key: key, size: 100 }, { key: thing_prefix.to_s, size: 0 }] } }
  let(:object_data) { { key => { body: 'meter-readings!' } } }

  before do
    FileUtils.mkdir_p config.local_bucket_path
    s3_client.stub_responses(:list_objects, list_of_objects)

    s3_client.stub_responses(:get_object, lambda { |context|
      obj = object_data[context.params[:key]]
      obj || 'NoSuchKey'
    })
  end

  it 'imports and archives files correctly' do
    expect_any_instance_of(Amr::CsvParserAndUpserter).to receive(:perform).and_return(nil)
    expect(s3_client).to receive(:copy_object).and_return(true)
    expect(s3_client).to receive(:delete_objects).and_return(true)
    subject.import_all
    expect(File.exist?(expected_local_file)).to eq false
  end

  it 'gets a list of everything in the bucket' do
    expect(subject.send(:get_array_of_files_in_bucket_with_prefix)).to eq [thing_name]
  end

  it 'downloads file from s3 to local file system' do
    subject.send(:get_file_from_s3, thing_name)
    expect(File.read(expected_local_file)).to eq 'meter-readings!'
  end

  it 'logs errors to Rollbar' do
    e = StandardError.new
    expect_any_instance_of(Amr::CsvParserAndUpserter).to receive(:perform).and_raise(e)
    expect(Rollbar).to receive(:error).with(e, job: :import_all, config: thing_prefix, file_name: thing_name)
    subject.import_all
  end
end
