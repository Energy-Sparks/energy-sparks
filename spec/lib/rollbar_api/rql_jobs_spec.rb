require 'rails_helper'
require 'rollbar_api/rql_jobs'

module RollbarApi
  describe RqlJobs do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:job) do
      { 'err': 0,
        'result': {
          'status': job_status,
          'job_hash': 'eea93bcc3cfc304027d70cd77b6326e03605ea66',
          'date_modified': 1_613_650_640,
          'query_string': 'query',
          'date_created': 1_613_650_632,
          'project_id': 193_054,
          'id': 95_683_968,
          'project_group_id': 20_954
        } }
    end
    let(:job_result) do
      {
        'err': 0,
        'result': {
          'job_id': 95_684_744,
          'result': {
            'isSimpleSelect': 'True',
            'errors': [],
            'warnings': ['No timestamp filter.'],
            'executionTime': 12.060364961624146,
            'effectiveTimestamp': 1_613_657_827,
            'rowcount': 2,
            'rows': [[1_607_577_513, 'Wimbledon High School', 564, 145_051_707_090], [1_607_491_119, 'Wimbledon High School', 564, 144_931_196_345]],
            'selectionColumns': ['timestamp', 'body.trace.extra.school_name'],
            'projectIds': [193_054, 193_054],
            'columns': ['timestamp', 'body.trace.extra.school_name', 'item.counter', 'occurrence_id']
          }
        }
      }
    end
    let(:client)      { Faraday.new { |b| b.adapter(:test, stubs) } }

    let(:api_token) { 'token' }
    let(:rql_jobs)  { RollbarApi::RqlJobs.new(api_token, client) }

    let(:query)     { 'select * from item_occurence' }

    after(:all) do
      Faraday.default_connection = nil
    end

    it 'raises error for missing config' do
      expect { RollbarApi::RqlJobs.new(nil) }.to raise_error(RuntimeError)
    end

    context 'when submitting a job' do
      let(:job_status) { 'new' }

      it 'call the API' do
        stubs.post('/api/1/rql/jobs') do |env|
          expect(env.body).to eql({
            'query_string': query,
            'access_token': api_token,
            'force_refresh': true
          }.to_json)
          [
            200,
            { 'Content-Type': 'application/json' },
            job.to_json
          ]
        end

        expect(rql_jobs.submit_job(query)).to be 95_683_968
        stubs.verify_stubbed_calls
      end

      it 'raises errors' do
        stubs.post('/api/1/rql/jobs') do |_env|
          [400, {}, '']
        end

        expect { rql_jobs.submit_job(query) }.to raise_error(RuntimeError)
        stubs.verify_stubbed_calls
      end
    end

    context 'when working with jobs' do
      let(:job_status) { 'running' }

      it 'gets a job' do
        stubs.get('/api/1/rql/job/12345') do |env|
          expect(env.params).to include('access_token' => api_token)
          [200, {}, '{}']
        end
        expect(rql_jobs.get_job(12_345)).to eql({})
        stubs.verify_stubbed_calls
      end

      it 'checks job status' do
        stubs.get('/api/1/rql/job/12345') do |env|
          expect(env.params).to include('access_token' => api_token)
          [200, {}, job.to_json]
        end
        expect(rql_jobs.job_status(12_345)).to eql('running')
        stubs.verify_stubbed_calls
      end

      it 'gets job result' do
        stubs.get('/api/1/rql/job/12345/result') do |env|
          expect(env.params).to include('access_token' => api_token)
          [200, {}, job_result.to_json]
        end
        result = rql_jobs.get_result(12_345)
        expect(result['result']['result']['rowcount']).to be(2)
        stubs.verify_stubbed_calls
      end
    end

    context 'when running a query' do
      let(:job_status) { 'success' }

      it 'runs a query' do
        stubs.post('/api/1/rql/jobs') do |_env|
          [200, {}, { "result": { "id": 4444 } }.to_json]
        end
        stubs.get('/api/1/rql/job/4444') do |_env|
          [200, {}, job.to_json]
        end
        stubs.get('/api/1/rql/job/4444/result') do |_env|
          [200, {}, job_result.to_json]
        end
        result = rql_jobs.run_query(query)
        expect(result['result']['result']['rowcount']).to be(2)
        stubs.verify_stubbed_calls
      end

      context 'with failed queries' do
        let(:job_status) { 'failed' }

        it 'handles cancelled, timeout, failed queries' do
          stubs.post('/api/1/rql/jobs') do |_env|
            [200, {}, { "result": { "id": 4444 } }.to_json]
          end
          stubs.get('/api/1/rql/job/4444') do |_env|
            [200, {}, job.to_json]
          end
          expect { rql_jobs.run_query(query) }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
