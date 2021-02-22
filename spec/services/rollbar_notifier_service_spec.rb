require 'rails_helper'

describe RollbarNotifierService do

  let(:rql_jobs)    { double("RollbarAPI::RQLJobs") }

  #this is a subset of what the Rollbar API returns
  let(:job_result) {
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
  }

  describe '#run_queries' do

    it "runs all the queries" do
      RollbarNotifierService::REPORTS.keys.each do |key|
        query = RollbarNotifierService::REPORTS[key][:rql_query]
        expect(rql_jobs).to receive(:run_query).with(query).and_return(job_result)
      end
      results = RollbarNotifierService.new(rql_jobs).run_queries
      expect(results.keys).to eql(RollbarNotifierService::REPORTS.keys)
    end

    it "includes the report configuration" do
        allow(rql_jobs).to receive(:run_query).and_return(job_result)

        results = RollbarNotifierService.new(rql_jobs).run_queries
        results.each do |key, reported_result|
          expect(reported_result[:title]).to_not be_nil
          expect(reported_result[:rql_query]).to_not be_nil
          expect(reported_result[:results]).to_not be_nil
          expect(reported_result[:results][:rows]).to eql(job_result["result"]["result"]["rows"])
          expect(reported_result[:results][:columns]).to eql(job_result["result"]["result"]["columns"])
          expect(reported_result[:results][:error]).to be_nil
        end
    end

    it "records an error when report failed" do
      allow(rql_jobs).to receive(:run_query).and_raise(RuntimeError)

      results = RollbarNotifierService.new(rql_jobs).run_queries
      results.each do |key, reported_result|
        expect(reported_result[:title]).to_not be_nil
        expect(reported_result[:rql_query]).to_not be_nil
        expect(reported_result[:results]).to_not be_nil
        expect(reported_result[:results][:rows]).to eql([])
        expect(reported_result[:results][:columns]).to eql([])
        expect(reported_result[:results][:error]).to eql(true)
      end

    end

  end

  describe '#perform' do
    it "generates an email" do
      allow(rql_jobs).to receive(:run_query).and_raise(RuntimeError)

      results = RollbarNotifierService.new(rql_jobs).perform

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Custom Error Reports')
      email_body = email.html_part.body.to_s
      expect(email_body).to include("Custom Error Reports")
    end

    it "the email includes all the reports" do
      allow(rql_jobs).to receive(:run_query).and_return(job_result)

      results = RollbarNotifierService.new(rql_jobs).perform
      email = ActionMailer::Base.deliveries.last
      email_body = email.html_part.body.to_s
      RollbarNotifierService::REPORTS.each do |key, report|
        expect(email_body).to include(report[:title])
      end
    end

    it "formats timestamps correctly" do
      allow(rql_jobs).to receive(:run_query).and_return(job_result)
      results = RollbarNotifierService.new(rql_jobs).perform
      email = ActionMailer::Base.deliveries.last
      email_body = email.html_part.body.to_s
      expect(email_body).to include("Thu 10th Dec 2020")
    end

    it "builds links to Rollbar" do
      allow(rql_jobs).to receive(:run_query).and_return(job_result)
      results = RollbarNotifierService.new(rql_jobs).perform
      email = ActionMailer::Base.deliveries.last
      email_body = email.html_part.body.to_s
      expect(email_body).to match(/href="https:\/\/rollbar.com\/energysparks\/EnergySparksTestEnvironment\/items\/564\/occurrences\/145051707090"/)
    end
  end
end
