require 'rails_helper'

describe RollbarNotifierService do
  let(:rql_jobs) { double("RollbarApi::RqlJobs") }

  #this is a subset of what the Rollbar API returns
  let(:job_result) do
      {
        'err' => 0,
        'result' => {
          'job_id' => 95684744,
          'result' => {
              'isSimpleSelect' => 'True',
              'errors' => [],
              'warnings' => ['No timestamp filter.'],
              'executionTime' => 12.060364961624146,
              'effectiveTimestamp' => 1613657827,
              'rowcount' => 2,
              'rows' => [[1607577513, 'Wimbledon High School', 564, 145051707090], [1607491119, 'Wimbledon High School', 564, 144931196345]],
              'selectionColumns' => ['timestamp', 'body.trace.extra.school_name'],
              'projectIds' => [293054, 293054],
              'columns' => ['timestamp', 'body.trace.extra.school_name', 'item.counter', 'occurrence_id']
          }
        }
      }
  end

  describe '#run_queries' do
    it "runs all the queries" do
      RollbarNotifierService::REPORTS.each_key do |key|
        query = RollbarNotifierService::REPORTS[key][:rql_query]
        expect(rql_jobs).to receive(:run_query).with(query).and_return(job_result)
      end
      results = RollbarNotifierService.new(rql_jobs).run_queries
      expect(results.keys).to eql(RollbarNotifierService::REPORTS.keys)
    end

    it "includes the report configuration" do
        allow(rql_jobs).to receive(:run_query).and_return(job_result)

        results = RollbarNotifierService.new(rql_jobs).run_queries
        results.each_value do |reported_result|
          expect(reported_result[:title]).not_to be_nil
          expect(reported_result[:rql_query]).not_to be_nil
          expect(reported_result[:results]).not_to be_nil
          expect(reported_result[:results][:rows]).to eql(job_result["result"]["result"]["rows"])
          expect(reported_result[:results][:columns]).to eql(job_result["result"]["result"]["columns"])
          expect(reported_result[:results][:error]).to be_nil
        end
    end

    it "records an error when report failed" do
      allow(rql_jobs).to receive(:run_query).and_raise(RuntimeError)

      results = RollbarNotifierService.new(rql_jobs).run_queries
      results.each_value do |reported_result|
        expect(reported_result[:title]).not_to be_nil
        expect(reported_result[:rql_query]).not_to be_nil
        expect(reported_result[:results]).not_to be_nil
        expect(reported_result[:results][:rows]).to eql([])
        expect(reported_result[:results][:columns]).to eql([])
        expect(reported_result[:results][:error]).to be(true)
      end
    end
  end

  describe '#perform' do
    it "generates an email" do
      allow(rql_jobs).to receive(:run_query).and_raise(RuntimeError)

      RollbarNotifierService.new(rql_jobs).perform

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Custom Error Reports')
      email_body = email.html_part.decoded
      expect(email_body).to include("Custom Error Reports")
    end

    it "the email includes all the reports" do
      allow(rql_jobs).to receive(:run_query).and_return(job_result)

      RollbarNotifierService.new(rql_jobs).perform
      email = ActionMailer::Base.deliveries.last
      email_body = email.html_part.decoded
      RollbarNotifierService::REPORTS.each_value do |report|
        expect(email_body).to include(report[:title])
      end
    end

    it "formats timestamps correctly" do
      allow(rql_jobs).to receive(:run_query).and_return(job_result)
      RollbarNotifierService.new(rql_jobs).perform
      email = ActionMailer::Base.deliveries.last
      email_body = email.html_part.decoded
      expect(email_body).to include("Thu 10th Dec 2020")
    end

    it "builds links to Rollbar" do
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: "Test" do
        allow(rql_jobs).to receive(:run_query).and_return(job_result)
        RollbarNotifierService.new(rql_jobs).perform
        email = ActionMailer::Base.deliveries.last
        email_body = email.html_part.decoded
        expect(email_body).to match(%r{href="https://rollbar.com/energysparks/EnergySparksTestEnvironment/items/564/occurrences/145051707090"})
      end
    end
  end
end
