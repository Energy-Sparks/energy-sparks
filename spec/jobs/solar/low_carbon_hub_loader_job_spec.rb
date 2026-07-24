# frozen_string_literal: true

require 'rails_helper'

describe Solar::LowCarbonHubLoaderJob do
  it_behaves_like 'a solar loader job' do
    let(:installation) do
      create(:solar_edge_installation)
    end
    let(:upserter_class) { Solar::LowCarbonHubDownloadAndUpsert }
    let(:solar_feed_type) { 'Rtone' }
    let(:installation_for) { installation.school.name }
  end
end
