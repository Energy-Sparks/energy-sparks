# frozen_string_literal: true

require 'rails_helper'

describe SolarEdgeInstallation do
  include_context 'with SolarEdge credentials'

  describe '#latest_reading' do
    subject(:solar_edge_installation) { create(:solar_edge_installation) }

    let(:latest_reading) { solar_edge_installation.latest_reading }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(latest_reading).to be_nil
      end
    end

    context 'when there is an electricity meter' do
      context 'with no readings' do
        before do
          create(:electricity_meter, mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i, pseudo: true,
                                     solar_edge_installation:)
        end

        it 'returns nil' do
          expect(latest_reading).to be_nil
        end
      end

      context 'with readings' do
        before do
          create(:electricity_meter_with_reading, mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i,
                                                  pseudo: true, solar_edge_installation:)
          solar_edge_installation.reload
        end

        it 'returns the latest date' do
          expect(latest_reading).to eq(Date.parse(AmrDataFeedReading.first.reading_date))
        end
      end
    end
  end

  describe '#site_id_unique_to_school' do
    let!(:solar_edge_installation) { create(:solar_edge_installation) }

    it 'allows multiple installations for the same school and site_id' do
      installation = build(:solar_edge_installation, site_id: solar_edge_installation.site_id,
                                                     school: solar_edge_installation.school)
      expect(installation).to be_valid
    end

    it 'does not allow the same site_id for different schools' do
      installation = build(:solar_edge_installation, site_id: solar_edge_installation.site_id)
      expect(installation).not_to be_valid
      expect(installation.errors[:site_id]).to eq(['is already associated with a different school'])
    end
  end

  describe '#access_token_expired?' do
    subject(:installation) { create(:solar_edge_installation) }

    context 'with current token' do
      it { expect(installation.access_token_expired?).to be(false) }
    end

    context 'with expired token' do
      subject(:installation) { create(:solar_edge_installation, :with_expired_access_token) }

      it { expect(installation.access_token_expired?).to be(true) }
    end

    context 'with expiring token' do
      subject(:installation) do
        create(:solar_edge_installation, access_token_expires_at: Time.now.utc + 1.second)
      end

      it { expect(installation.access_token_expired?).to be(true) }
    end
  end

  describe '#monitoring_active?' do
    it 'checks status correctly' do
      expect(create(:solar_edge_installation).monitoring_active?).to be(true)
      expect(create(:solar_edge_installation, :pending_status).monitoring_active?).to be(false)
    end

    context 'when no information' do
      it 'returns nil' do
        expect(create(:solar_edge_installation, information: nil).monitoring_active?).to be(false)
        expect(create(:solar_edge_installation, information: {}).monitoring_active?).to be(false)
      end
    end

    context 'when checking v1 status' do
      subject(:installation) do
        create(:solar_edge_installation, information: {
                 'site_details' => {
                   'sites' => {
                     'site' => [
                       {
                         'status' => 'Active'
                       }
                     ]
                   }
                 }
               })
      end

      it 'checks status' do
        expect(installation.monitoring_active?).to be(true)
      end
    end
  end

  describe '#refresh_api_tokens!' do
    subject!(:installation) { create(:solar_edge_installation, :with_expired_access_token) }

    context 'when not consented' do
      subject!(:installation) { create(:solar_edge_installation, :unconsented) }

      it 'does nothing' do
        expect { installation.refresh_api_tokens! }.not_to(change { installation.reload.updated_at })
      end
    end

    context 'when there is an API error' do
      before do
        stub_request(:post, "#{DataFeeds::SolarEdge::Api::API_BASE}/oauth2/token")
          .to_return(
            status: 400,
            headers: {
              'Content-Type' => 'application/json'
            },
            body: {
              error: 'invalid_request'
            }.to_json
          )
      end

      it 'throws an exception' do
        expect { installation.refresh_api_tokens! }.to raise_error(Faraday::Error)
      end
    end

    context 'when there is a successful response' do
      before do
        stub_request(:post, "#{DataFeeds::SolarEdge::Api::API_BASE}/oauth2/token")
          .with do |request|
            body = JSON.parse(request.body)
            body['refresh_token'] == installation.refresh_token
          end
          .to_return(
            status: 200,
            headers: {
              'Content-Type' => 'application/json'
            },
            body: {
              access_token: 'new-access-token',
              refresh_token: 'new-refresh-token',
              expires_in: '7200'
            }.to_json
          )
      end

      it 'saves the updated tokens and expiry timestamp' do
        installation.refresh_api_tokens!
        expect(installation.reload).to have_attributes(
          access_token: 'new-access-token',
          refresh_token: 'new-refresh-token'
        )
        expect(installation.access_token_expires_at).to be_within(5.seconds).of(2.hours.from_now)
      end

      context 'when token refresh succeeds but saving fails' do
        before do
          allow(Rollbar).to receive(:error)
          # rubocop:disable-next RSpec/SubjectStub
          allow(installation).to receive(:update!)
            .and_raise(ActiveRecord::RecordInvalid.new(installation))
        end

        it 'logs the replacement tokens and re-raises the exception' do
          expect do
            installation.refresh_api_tokens!
          end.to raise_error(ActiveRecord::RecordInvalid)

          expect(Rollbar).to have_received(:error).with(
            instance_of(ActiveRecord::RecordInvalid),
            solar_edge_installation: installation.id,
            tokens: {
              'access_token' => 'new-access-token',
              'refresh_token' => 'new-refresh-token',
              'expires_in' => '7200'
            }
          )
        end
      end
    end
  end

  describe '#metadatcached_meter_metadataa_for_meter_type' do
    context 'when no information' do
      subject(:installation) { create(:solar_edge_installation, information: nil) }

      it 'returns nil' do
        expect(installation.cached_meter_metadata(:solar_pv)).to be_nil
      end
    end

    context 'when no inventory' do
      subject(:installation) { create(:solar_edge_installation, information: {}) }

      it 'returns nil' do
        expect(installation.cached_meter_metadata(:solar_pv)).to be_nil
      end
    end

    context 'when there is an inventory' do
      subject(:installation) { create(:solar_edge_installation) }

      it 'returns the meter metadata' do
        expect(installation.cached_meter_metadata(:exported_solar_pv)).to match(
          hash_including(
            'type' => 'METER',
            'meterType' => 'FeedIn',
            'name' => 'Export Meter'
          )
        )
        expect(installation.cached_meter_metadata(:electricity)).to match(
          hash_including(
            'type' => 'METER',
            'meterType' => 'Purchased',
            'name' => 'Import Meter'
          )
        )
      end
    end
  end
end
