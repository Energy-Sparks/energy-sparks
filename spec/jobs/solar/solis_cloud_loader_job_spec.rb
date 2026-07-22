# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolisCloudLoaderJob do
  it_behaves_like 'a solar loader job' do
    let(:installation) do
      create(:solar_pv_meter, solis_cloud_installation: create(:solis_cloud_installation)).solis_cloud_installation
    end
    let(:upserter_class) { Solar::SolisCloudDownloadAndUpsert }
    let(:solar_feed_type) { 'SolisCloud' }
  end
end
