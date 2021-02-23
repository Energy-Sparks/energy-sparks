require 'json'
require 'faraday'

module RollbarAPI
  API_BASE = "https://api.rollbar.com".freeze
  FAILED_STATES = %w[failed cancelled timed_out].freeze
  END_STATES = FAILED_STATES + ["success"]

  class RQLJobs
    def initialize(api_token, client = nil)
      @client = if client != nil
        client
                else
        Faraday.new(API_BASE, request: { timeout: 20 })
                end
      raise "ROLLBAR_READ_ACCESS_TOKEN not configured" unless api_token
      @api_token = api_token
    end

    def submit_job(query)
      body = {
        query_string: query,
        access_token: @api_token
      }
      resp = @client.post("/api/1/rql/jobs") do |req|
        req.body = body.to_json
      end
      raise "Unable to submit job" unless resp.success?
      json = JSON.parse(resp.body)
      return json["result"]["id"]
    end

    def job_status(job_id)
      json = get_job(job_id)
      return json["result"]["status"]
    end

    def get_job(job_id)
      resp = @client.get("/api/1/rql/job/#{job_id}", {
        access_token: @api_token
      })
      raise "Unable to get job" unless resp.success?
      json = JSON.parse(resp.body)
      return json
    end

    def get_result(job_id)
      resp = @client.get("/api/1/rql/job/#{job_id}/result", {
        access_token: @api_token
      })
      raise "Unable to fetch RQL results" unless resp.success?
      json = JSON.parse(resp.body)
      return json
    end

    def run_query(query)
      job_id = submit_job(query)
      status = job_status(job_id)
      status = job_status(job_id) until END_STATES.include?(status)
      raise "RQL query failed #{status}" if FAILED_STATES.include?(status)
      return get_result(job_id)
    end
  end
end
