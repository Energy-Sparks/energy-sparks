require 'rails_helper'

describe Solar::SolarEdgeLoaderJob do
  include Rails.application.routes.url_helpers
  let!(:installation) { create(:solar_edge_installation) }
  let(:job)           { Solar::SolarEdgeLoaderJob.new }

  let!(:import_log)    { create(:amr_data_feed_import_log, records_updated: 4, records_imported: 100) }
  let(:upserter)       { instance_double(Solar::SolarEdgeDownloadAndUpsert, perform: nil, import_log: import_log) }

  include_context 'when sending solar loader job emails'

  describe '#perform' do
    let(:job_result)  do
      job.perform(installation: installation, start_date: start_date, end_date: end_date, notify_email: admin.email)
    end

    context 'when the load is successful' do
      before do
        allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_return(upserter)
      end

      it 'calls the upserter' do
        expect(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).with(start_date: start_date, end_date: end_date,
                                                                        installation: installation)
        job_result
      end

      context 'when sending the email' do
        before do
          job_result
        end

        it_behaves_like 'a successful solar loader job', solar_feed_type: 'Solar Edge' do
          let(:installation_for) { installation.school.name }
        end
      end
    end

    context 'when the load is unsuccessful' do
      let!(:import_log) { create(:amr_data_feed_import_log, error_messages: 'There are errors here') }

      before do
        allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_return(upserter)
      end

      context 'with a loading error' do
        before do
          job_result
        end

        it_behaves_like 'a solar loader job with loader errors', solar_feed_type: 'Solar Edge' do
          let(:installation_for) { installation.school.name }
        end
      end

      context 'with an unexpected exception' do
        before do
          allow(Solar::SolarEdgeDownloadAndUpsert).to receive(:new).and_raise('Its broken')
          expect(Rollbar).to receive(:error).with(anything, hash_including(job: :import_solar_edge_readings)) # rubocop:disable RSpec/ExpectInHook
          job_result
        end

        it_behaves_like 'a solar loader job that had an exception', solar_feed_type: 'Solar Edge' do
          let(:installation_for) { installation.school.name }
        end
      end
    end
  end
end
