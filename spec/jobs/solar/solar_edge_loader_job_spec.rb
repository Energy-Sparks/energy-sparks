# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolarEdgeLoaderJob do
  it_behaves_like 'a solar loader job' do
    let(:installation) { create(:solar_edge_installation) }
    let(:upserter_class) { Solar::SolarEdgeDownloadAndUpsert }
    let(:solar_feed_type) { 'Solar Edge' }
    let(:installation_for) { installation.school.name }
  end
end
