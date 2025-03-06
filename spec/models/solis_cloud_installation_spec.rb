# frozen_string_literal: true

require 'rails_helper'

describe SolisCloudInstallation do
  subject(:installation) { create(:solis_cloud_installation) }

  describe '#latest_electricity_reading' do
    it 'gets a reading' do
      create(:electricity_meter_with_reading, solis_cloud_installation: installation, reading_date_format: '%Y-%m-%d',
                                              reading_count: 2)
      expect(installation.latest_electricity_reading).to eq(Date.new(2019, 6, 1))
    end

    it 'returns nil with no meter' do
      expect(installation.latest_electricity_reading).to be_nil
    end
  end
end
