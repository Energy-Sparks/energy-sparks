# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe AmrImportJob do
  include ActiveJob::TestHelper

  let(:bucket) { 'test-bucket' }
  let(:thing_prefix) { 'this-path' }
  let(:thing_name) { 'test-thing.csv' }
  let(:key) { "#{thing_prefix}/20250325-125200/#{thing_name}" }

  let(:config) { create(:amr_data_feed_config, identifier: thing_prefix) }

  let(:s3_client) { Aws::S3::Client.new(stub_responses: true) }

  # responses from AWS API to stub out network calls in client
  let(:list_of_objects) { { contents: [{ key: }, { key: "#{thing_prefix}/" }] } }
  let(:object_data) { { key => { body: 'meter-readings!' } } }

  before do
    s3_client.stub_responses(:list_objects_v2, list_of_objects)
    s3_client.stub_responses(:get_object, lambda { |context|
      object_data[context.params[:key]] || 'NoSuchKey'
    })
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    allow(ENV).to receive(:fetch).with('AWS_S3_AMR_DATA_FEEDS_BUCKET').and_return(bucket)
  end

  it 'imports and archives files correctly' do
    described_class.import_all(config)
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.size).to eq(1)
    perform_enqueued_jobs
    expect(s3_client.api_requests.pluck(:operation_name)).to \
      eq(%i[list_objects_v2 get_object copy_object delete_object])
    expect(s3_client.api_requests[2][:params]).to \
      eq({ bucket:, copy_source: "#{bucket}/#{key}", key: "archive-#{thing_prefix}/20250325-125200/#{thing_name}" })
    expect(s3_client.api_requests[3][:params]).to eq({ bucket:, key: })
  end

  it 'logs errors to Rollbar' do
    e = StandardError.new
    allow(Amr::CsvParserAndUpserter).to receive(:perform).and_raise(e)
    allow(Rollbar).to receive(:error)
    perform_enqueued_jobs { described_class.import_all(config) }
    expect(Rollbar).to \
      have_received(:error).with(e, hash_including(job: :amr_import_job, bucket:, config: thing_prefix, key:))
  end

  context 'with non breaking space' do
    let(:thing_name) { "test\u00A0thing.csv" }

    it 'encodes the copy source' do
      perform_enqueued_jobs { described_class.import_all(config) }
      expect(s3_client.api_requests[2][:params][:copy_source]).to \
        eq('test-bucket/this-path/20250325-125200/test%C2%A0thing.csv')
    end
  end
end
