# frozen_string_literal: true

require 'rails_helper'

describe Solar::MeterZLoaderJob do
  it_behaves_like 'a solar loader job' do
    let(:installation) do
      create(:solar_pv_meter, meter_z_installation: create(:meter_z_installation)).meter_z_installation
    end
    let(:upserter_class) { Solar::MeterZDownloadAndUpsert }
    let(:solar_feed_type) { 'MeterZ' }
    let(:installation_for) { installation.display_name }
  end
end
