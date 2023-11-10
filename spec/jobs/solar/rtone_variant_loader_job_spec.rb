require 'rails_helper'

describe Solar::RtoneVariantLoaderJob do
  include Rails.application.routes.url_helpers
  let!(:installation) { create(:solar_edge_installation) }
  let(:job)           { Solar::RtoneVariantLoaderJob.new }

  let!(:import_log)    { create(:amr_data_feed_import_log, records_updated: 4, records_imported: 100) }
  let(:upserter)       { instance_double(Solar::RtoneVariantDownloadAndUpsert, perform: nil, import_log: import_log) }

  include_context "when sending solar loader job emails"

  describe '#perform' do
    let(:job_result)  { job.perform(installation: installation, start_date: start_date, end_date: end_date, notify_email: admin.email) }

    context 'when the load is successful' do
      before do
        allow(Solar::RtoneVariantDownloadAndUpsert).to receive(:new).and_return(upserter)
      end

      it 'calls the upserter' do
        expect(Solar::RtoneVariantDownloadAndUpsert).to receive(:new).with(start_date: start_date, end_date: end_date, installation: installation)
        job_result
      end

      context 'when sending the email' do
        before do
          job_result
        end

        it_behaves_like 'a successful solar loader job', solar_feed_type: 'Rtone Variant'
      end
    end

    context 'when the load is unsuccessful' do
      let!(:import_log) { create(:amr_data_feed_import_log, error_messages: "There are errors here") }

      before do
        allow(Solar::RtoneVariantDownloadAndUpsert).to receive(:new).and_return(upserter)
      end

      context 'with a loading error' do
        before do
          job_result
        end

        it_behaves_like 'a solar loader job with loader errors', solar_feed_type: 'Rtone Variant'
      end

      context 'with an unexpected exception' do
        before do
          allow(Solar::RtoneVariantDownloadAndUpsert).to receive(:new).and_raise("Its broken")
          #rubocop:disable RSpec/ExpectInHook
          expect(Rollbar).to receive(:error).with(anything, job: :import_solar_edge_readings)
          #rubocop:enable RSpec/ExpectInHook
          job_result
        end

        it_behaves_like 'a solar loader job that had an exception', solar_feed_type: 'Rtone Variant'
      end
    end
  end
end
