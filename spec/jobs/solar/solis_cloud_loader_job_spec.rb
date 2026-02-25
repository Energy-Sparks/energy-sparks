# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolisCloudLoaderJob do
  include Rails.application.routes.url_helpers
  subject(:job) { described_class.new }

  let!(:installation) do
    installation = create(:solis_cloud_installation)
    create(:solar_pv_meter, solis_cloud_installation: installation)
    installation
  end
  let(:upserter) { instance_double(Solar::SolisCloudDownloadAndUpsert, perform: nil, import_log:) }

  include_context 'when sending solar loader job emails'

  def perform_job
    job.perform(installation:, start_date:, end_date:, notify_email: admin.email)
  end

  describe '#perform' do
    let(:mock) { allow(Solar::SolisCloudDownloadAndUpsert).to receive(:new).and_return(upserter) }

    before do
      mock
      perform_job
    end

    context 'when the load is successful' do
      let!(:import_log) { create(:amr_data_feed_import_log, records_updated: 4, records_imported: 100) }

      it 'calls the upserter' do
        expect(upserter).to have_received(:perform)
      end

      context 'when sending the email' do
        it_behaves_like 'a successful solar loader job', solar_feed_type: 'SolisCloud' do
          let(:installation_for) { installation.display_name }
        end
      end
    end

    context 'when the load is unsuccessful' do
      let!(:import_log) { create(:amr_data_feed_import_log, error_messages: 'There are errors here') }

      context 'with a loading error' do
        it_behaves_like 'a solar loader job with loader errors', solar_feed_type: 'SolisCloud' do
          let(:installation_for) { installation.display_name }
        end
      end

      context 'with an unexpected exception' do
        let(:mock) { allow(Solar::SolisCloudDownloadAndUpsert).to receive(:new).and_raise('Its broken') }

        it_behaves_like 'a solar loader job that had an exception', solar_feed_type: 'SolisCloud' do
          let(:installation_for) { installation.display_name }
        end
      end
    end
  end
end
