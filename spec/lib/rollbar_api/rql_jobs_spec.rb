require 'rails_helper'
require 'rollbar_api/rql_jobs.rb'

module RollbarApi
  describe RqlJobs do

    let(:stubs)     { Faraday::Adapter::Test::Stubs.new }
    let(:client)      { Faraday.new { |b| b.adapter(:test, stubs) } }

    let(:api_token) { "token"}
    let(:rql_jobs)  { RollbarApi::RqlJobs.new(api_token, client)}

    let(:query)     { "select * from item_occurence" }

    after(:all) do
      Faraday.default_connection = nil
    end

    let(:job) {
        { 'err': 0,
          'result': {
            'status': job_status,
            'job_hash': 'eea93bcc3cfc304027d70cd77b6326e03605ea66',
            'date_modified': 1613650640,
            'query_string': 'query',
            'date_created': 1613650632,
            'project_id': 193054,
            'id': 95683968,
            'project_group_id': 20954
          }
        }
    }

    let(:job_result) {
        {
          'err': 0,
          'result': {
            'job_id': 95684744,
            'result': {
                'isSimpleSelect': 'True',
                'errors': [],
                'warnings': ['No timestamp filter.'],
                'executionTime': 12.060364961624146,
                'effectiveTimestamp': 1613657827,
                'rowcount': 2,
                'rows': [[1607577513, 'Wimbledon High School', 564, 145051707090], [1607491119, 'Wimbledon High School', 564, 144931196345]],
                'selectionColumns': ['timestamp', 'body.trace.extra.school_name'],
                'projectIds': [193054, 193054],
                'columns': ['timestamp', 'body.trace.extra.school_name', 'item.counter', 'occurrence_id']
            }
          }
        }
    }

    it 'raises error for missing config' do
      expect{ RollbarApi::RqlJobs.new(nil) }.to raise_error(RuntimeError)
    end

    context 'when submitting a job' do
      let(:job_status) { "new" }

      it 'call the API' do
        stubs.post("/api/1/rql/jobs") do |env|
          expect(env.body).to eql({
              'query_string': query,
              'access_token': api_token
          }.to_json)
          [
            200,
            { 'Content-Type': "application/json"},
            job.to_json
          ]
        end

        expect( rql_jobs.submit_job(query) ).to eql 95683968
        stubs.verify_stubbed_calls
      end

      it 'raises errors' do
        stubs.post("/api/1/rql/jobs") do |env|
          [400, {}, ""]
        end

        expect{ rql_jobs.submit_job(query) }.to raise_error(RuntimeError)
        stubs.verify_stubbed_calls
      end

    end

    context 'when working with jobs' do

      let(:job_status) { "running" }

      it 'gets a job' do
        stubs.get("/api/1/rql/job/12345") do |env|
          expect(env.params).to include("access_token" => api_token)
          [200, {}, "{}"]
        end
        expect(rql_jobs.get_job(12345) ).to eql({})
        stubs.verify_stubbed_calls
      end

      it 'checks job status' do
        stubs.get("/api/1/rql/job/12345") do |env|
          expect(env.params).to include("access_token" => api_token)
          [200, {}, job.to_json]
        end
        expect(rql_jobs.job_status(12345) ).to eql("running")
        stubs.verify_stubbed_calls
      end

      it 'gets job result' do
        stubs.get("/api/1/rql/job/12345/result") do |env|
          expect(env.params).to include("access_token" => api_token)
          [200, {}, job_result.to_json]
        end
        result = rql_jobs.get_result(12345)
        expect( result["result"]["result"]["rowcount"] ).to eql(2)
        stubs.verify_stubbed_calls
      end

    end

    context 'when running a query' do
      let(:job_status) { "success" }

      it 'runs a query' do
        stubs.post("/api/1/rql/jobs") do |env|
          [200, {}, { "result": { "id": 4444 }}.to_json
          ]
        end
        stubs.get("/api/1/rql/job/4444") do |env|
          [200, {}, job.to_json]
        end
        stubs.get("/api/1/rql/job/4444/result") do |env|
          [200, {}, job_result.to_json]
        end
        result = rql_jobs.run_query(query)
        expect( result["result"]["result"]["rowcount"] ).to eql(2)
        stubs.verify_stubbed_calls
      end

      context 'with failed queries' do
        let(:job_status) { "failed" }

        it 'handles cancelled, timeout, failed queries' do
          stubs.post("/api/1/rql/jobs") do |env|
            [200, {}, { "result": { "id": 4444 }}.to_json
            ]
          end
          stubs.get("/api/1/rql/job/4444") do |env|
            [200, {}, job.to_json]
          end
          expect{ rql_jobs.run_query(query) }.to raise_error(RuntimeError)
        end

      end
    end
  end
end
