require 'rails_helper'

describe Solar::SolarEdgeLoaderJob do
  include Rails.application.routes.url_helpers

  let!(:admin)        { create(:admin) }
  let!(:installation) { create(:solar_edge_installation) }
  let(:job)           { Solar::SolarEdgeLoaderJob.new }

  let(:start_date)    { nil }
  let(:end_date)      { nil }

  let(:import_log)    { create(:amr_data_feed_import_log, records_updated: 4, records_imported: 100) }
  let(:upserter)      { instance_double(Solar::SolarEdgeDownloadAndUpsert, perform: nil, import_log: import_log) }

  let(:email)         { ActionMailer::Base.deliveries.last }
  #access to html might change depending on type of email sent, e.g. mail vs make_bootstrap_mail
  #this returns the html body as a string
  let(:email_body)    { email.html_part.body.decoded }
  let(:email_subject) { email.subject }
  #parse the html string into something we can match against
  let(:html_email)    { Capybara::Node::Simple.new(email_body) }

  describe '#perform' do
    let(:job_result)  { job.perform(installation: installation, start_date: start_date, end_date: end_date, notify_email: admin.email) }

    context 'when the load is successful' do
      let(:title)       { "Solar Edge Import for #{installation.school.name}" }
      let(:results_url) { school_meters_path(installation.school) }

      before do
        allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_return(upserter)
      end

      it 'reports the success via email' do
        expect(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).with(start_date: start_date, end_date: end_date, installation: installation)

        job_result

        expect(email_subject).to eq "[energy-sparks-unknown] #{title}"
        expect(html_email).to have_link("view the results here", href: results_url)
        expect(html_email).to have_text("The requested import for the Solar Edge Site Id #{installation.site_id} has completed")
        expect(html_email).to have_text("100 records were imported and 4 updated")
      end
    end

    context 'when the load is unsuccessful' do
      let(:import_log)    { create(:amr_data_feed_import_log, error_messages: "There are errors here") }
      let(:results_url)   { admin_reports_amr_data_feed_import_logs_errors_path({ config: { config_id: import_log.amr_data_feed_config.id } }) }

      before do
        allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_return(upserter)
      end

      context 'with a loading error' do
        it 'reports the error messages via email' do
          expect(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).with(start_date: start_date, end_date: end_date, installation: installation)
          job_result
          expect(html_email).to have_text("The requested import for the Solar Edge Site Id #{installation.site_id} has failed")
          expect(html_email).to have_text("There are errors here")
          expect(html_email).to have_link("view the results here", href: results_url)
        end
      end

      context 'with an unexpected exception' do
        before do
          allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_raise("Its broken")
        end

        it 'reports the failure via email' do
          job_result
          expect(html_email).to have_text("The job failed to run. An error has been logged: Its broken")
        end

        it 'reports to Rollbar' do
          expect(Rollbar).to receive(:error).with(anything, job: :import_solar_edge_readings)
          job_result
        end
      end
    end
  end
end
