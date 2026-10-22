# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolarEdgeService do
  subject(:service) { described_class.new(installation) }

  describe '#update_information' do
    let!(:installation) { create(:solar_edge_installation, information: nil) }
    let(:site_id) { installation.site_id }

    context 'with an ACTIVE site' do
      include_context 'with a stubbed SolarEdge site details request'
      include_context 'with a stubbed SolarEdge date request'
      include_context 'with a stubbed SolarEdge inventory request'

      before { service.update_information }

      it 'updates the site_details' do
        expect(installation.reload.information['site_details']).to match(
          hash_including(
            'siteId' => site_id,
            'activationStatus' => 'ACTIVE'
          )
        )
      end

      it 'updates the dates' do
        expect(installation.reload.information['dates']).to eq(
          {
            'from' => '2024-01-01T00:00:00+01:00',
            'to' => '2026-01-02T13:43:01+01:00'
          }
        )
      end

      it 'updates the inventory' do
        expect(installation.reload.information['inventory']).to eq(
          [
            { 'type' => 'METER', 'active' => true, 'meterType' => 'FeedIn', 'name' => 'Export Meter',
              'serialNumber' => '12345' },
            { 'type' => 'METER', 'active' => true, 'meterType' => 'Purchased', 'name' => 'Import Meter',
              'serialNumber' => '12345' },
            { 'type' => 'METER', 'active' => true, 'meterType' => 'SelfConsumption', 'name' => 'Self Consumption' },
            { 'type' => 'METER', 'active' => true, 'meterType' => 'Consumption', 'name' => 'Consumption Meter' }
          ]
        )
      end
    end

    context 'with a PENDING site' do
      include_context 'with a stubbed SolarEdge site details request' do
        let(:activation_status) { 'PENDING' }
      end

      include_context 'with a stubbed SolarEdge inventory request'

      before do
        service.update_information
      end

      it 'updates only the site_details and dates' do
        expect(installation.reload.information.keys).to contain_exactly('site_details', 'inventory', 'dates')
        expect(installation.reload.information['dates']).to be_empty
      end
    end
  end

  describe '#check' do
    context 'with a successful check' do
      include_context 'with a successful SolarEdge token request' do
        # rubocop:disable-next RSpec/LetSetup
        let!(:installation) { create(:solar_edge_installation, :with_expired_access_token) }
      end

      it { expect(service.check).to be(true) }
    end

    context 'with an unsuccessful check' do
      include_context 'with a failed SolarEdge token request' do
        # rubocop:disable-next RSpec/LetSetup
        let!(:installation) { create(:solar_edge_installation, :with_expired_access_token) }
      end

      it { expect(service.check).to be(false) }
    end
  end

  describe '#setup_meters' do
    context 'when setup is already complete' do
      subject!(:installation) { create(:solar_edge_installation, :with_electricity_meter) }

      it { expect(service.setup_meters).to be_nil }
    end

    context 'when not consented' do
      subject!(:installation) { create(:solar_edge_installation, :unconsented) }

      it { expect(service.setup_meters).to be_nil }
    end

    context 'when ready to be setup' do
      subject!(:installation) { create(:solar_edge_installation) }

      include_context 'with a stubbed SolarEdge date request' do
        let(:site_id) { installation.site_id }
      end

      it 'schedules loading job' do
        service.setup_meters
        expect(Solar::SolarEdgeLoaderJob).to have_been_enqueued
      end
    end
  end
end
