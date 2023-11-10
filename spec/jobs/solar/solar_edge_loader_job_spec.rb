require 'rails_helper'

describe Solar::SolarEdgeLoaderJob do
  include Rails.application.routes.url_helpers

  let!(:admin)        { create(:admin) }
  let!(:installation) { create(:solar_edge_installation) }
  let(:job)           { Solar::SolarEdgeLoaderJob.new }

  let(:start_date)    { nil }
  let(:end_date)      { nil }
  let(:result)        { true }

  let(:import_log)    { create(:amr_data_feed_import_log) }
  let(:upserter)      { instance_double(Solar::SolarEdgeDownloadAndUpsert, perform: result, import_log: import_log) }

  # rubocop:disable RSpec/VerifiedDoubles
  # Rubocop doesn't like use of the double() here, but also don't allow use of receive_message_chain
  # But this seems more concise to me, as I just want to set expections around the call to the
  # Mailer. Not sure of a better way to do this.
  let(:mailer)        { instance_double(AdminMailer, background_job_complete: double(deliver: result)) }
  # rubocop:enable RSpec/VerifiedDoubles

  describe '#perform' do
    let(:job_result)  { job.perform(installation, start_date, end_date, admin.email) }

    context 'when the load is successful' do
      let(:title)       { "Solar Edge Import for #{installation.school.name}" }
      let(:results_url) { school_meters_path(installation.school) }

      before do
        allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_return(upserter)
        allow(AdminMailer).to receive(:with).and_return(mailer)
      end

      it 'reports the success via email' do
        expect(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).with(start_date: start_date, end_date: end_date, installation: installation)
        expect(AdminMailer).to receive(:with).with(to: admin.email, title: title, summary: anything, results_url: results_url)
        expect(job_result).to eq(result)
      end
    end

    context 'when the load is unsuccessful' do
      let(:import_log) { create(:amr_data_feed_import_log) }

      context 'with a loading error' do
        it 'reports the error messages via email'
      end

      context 'with an unexpected exception' do
        it 'reports the failure via email'
      end
    end
  end
end
