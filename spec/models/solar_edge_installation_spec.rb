# frozen_string_literal: true

require 'rails_helper'

describe SolarEdgeInstallation do
  around do |example|
    ClimateControl.modify SOLAR_EDGE_CLIENT_ID: 'solar_edge_client_id', SOLAR_EDGE_CLIENT_SECRET: 'solar_edge_secret' do
      example.run
    end
  end

  describe '#electricity_meter' do
    subject(:solar_edge_installation) { create(:solar_edge_installation) }

    let(:meter) { solar_edge_installation.electricity_meter }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(meter).to be_nil
      end
    end

    context 'when there is only an electricity meter' do
      subject(:solar_edge_installation) { create(:solar_edge_installation, :with_electricity_meter) }

      it 'returns the meter' do
        expect(meter).to eq(solar_edge_installation.meters.first)
      end
    end

    context 'when all meters are present' do
      subject(:solar_edge_installation) { create(:solar_edge_installation_with_meters_and_validated_readings) }

      it 'returns the meter' do
        expect(meter).to eq(Meter.electricity.first)
      end
    end
  end

  describe '#latest_electricity_reading' do
    subject(:solar_edge_installation) { create(:solar_edge_installation) }

    let(:latest_electricity_reading) { solar_edge_installation.latest_electricity_reading }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(latest_electricity_reading).to be_nil
      end
    end

    context 'when there is an electricity meter' do
      context 'with no readings' do
        before do
          create(:electricity_meter, mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i, pseudo: true,
                                     solar_edge_installation:)
        end

        it 'returns nil' do
          expect(latest_electricity_reading).to be_nil
        end
      end

      context 'with readings' do
        before do
          create(:electricity_meter_with_reading, mpan_mprn: 60_000_000_000_000 + solar_edge_installation.mpan.to_i,
                                                  pseudo: true, solar_edge_installation:)
        end

        it 'returns the latest date' do
          expect(latest_electricity_reading).to eq(Date.parse(AmrDataFeedReading.first.reading_date))
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

  describe '#refresh_api_tokens!' do
    subject!(:installation) { create(:solar_edge_installation) }

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
end
