# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe Amr::Importer do
  include ActiveJob::TestHelper

  subject(:amr_importer) { described_class.new(config, bucket) }

  let(:bucket)        { 'test-bucket' }
  let(:thing_prefix)  { 'this-path' }
  let(:thing_name)    { 'test-thing.csv' }
  let(:key)           { "#{thing_prefix}/#{thing_name}" }

  let(:config)        { create(:amr_data_feed_config, identifier: thing_prefix) }

  let(:expected_local_file) { "#{config.local_bucket_path}/#{thing_name}" }

  let(:s3_client) { Aws::S3::Client.new(stub_responses: true) }

  # responses from AWS API to stub out network calls in client
  let(:list_of_objects) { { contents: [{ key: }, { key: "#{thing_prefix}/" }] } }
  let(:object_data) { { key => { body: 'meter-readings!' } } }

  before do
    FileUtils.mkdir_p config.local_bucket_path
    s3_client.stub_responses(:list_objects_v2, list_of_objects)
    s3_client.stub_responses(:get_object, lambda { |context|
      object_data[context.params[:key]] || 'NoSuchKey'
    })
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
  end

  it 'imports and archives files correctly' do
    allow(Amr::CsvParserAndUpserter).to receive(:new) do |config, filename|
      expect(config.identifier).to eq(thing_prefix)
      expect(filename).to eq(thing_name)
      expect(File.read(expected_local_file)).to eq('meter-readings!')
      instance_double(Amr::CsvParserAndUpserter, perform: nil)
    end
    amr_importer.import_all
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.size).to eq(1)
    perform_enqueued_jobs
    expect(s3_client.api_requests.pluck(:operation_name)).to \
      eq([:list_objects_v2, :get_object, :copy_object, :delete_object])
    expect(s3_client.api_requests[2][:params]).to \
      eq({ bucket:, copy_source: "#{bucket}/#{key}", key: "archive-this-path/#{thing_name}" })
    expect(s3_client.api_requests[3][:params]).to eq({ bucket:, key: })
    expect(File.exist?(expected_local_file)).to be false
  end

  it 'logs errors to Rollbar' do
    e = StandardError.new
    expect_any_instance_of(Amr::CsvParserAndUpserter).to receive(:perform).and_raise(e)
    expect(Rollbar).to receive(:error).with(e, job: :import_all, bucket:, config: thing_prefix, key:)
    perform_enqueued_jobs { amr_importer.import_all }
  end
end
