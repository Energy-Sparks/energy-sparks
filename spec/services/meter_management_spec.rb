# frozen_string_literal: true

require 'rails_helper'

describe MeterManagement do
  let!(:meter) { create(:electricity_meter) }
  let(:config) { create(:amr_data_feed_config) }
  let(:log) { create(:amr_data_feed_import_log) }

  describe 'process_creation!' do
    let!(:amr_data_feed_reading) do
      create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log,
                                     mpan_mprn: meter.mpan_mprn, meter: nil)
    end
    let(:user) { create(:admin) }

    it 'assigns amr_data_feed_readings to the meter' do
      described_class.new(meter).process_creation!(user)
      expect(meter.amr_data_feed_readings).to contain_exactly(amr_data_feed_reading)
    end

    it 'queues a job to check dcc' do
      allow(DccCheckerJob).to receive(:perform_later)
      described_class.new(meter).process_creation!(user)
      expect(DccCheckerJob).to have_received(:perform_later).with(meter, user.email).once
    end

    it 'does not queue a dcc check job for a pseudo meter' do
      pseudo_meter = create(:electricity_meter, pseudo: true, mpan_mprn: 91_234_567_890_123)
      allow(DccCheckerJob).to receive(:perform_later)
      described_class.new(pseudo_meter).process_creation!(user)
      expect(DccCheckerJob).not_to have_received(:perform_later)
    end
  end

  describe 'process_mpan_mpnr_change!' do
    let!(:existing_amr_data_feed_reading) do
      create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log, meter: meter)
    end
    let!(:existing_amr_validated_reading) { create(:amr_validated_reading, meter: meter) }

    let!(:unassigned_amr_data_feed_reading) do
      create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log,
                                     mpan_mprn: meter.mpan_mprn, meter: nil)
    end

    context 'when the mpan_mprn has changed' do
      it 'assigns amr_data_feed_readings to the meter using the new mpan_mprn' do
        described_class.new(meter).process_mpan_mpnr_change!
        unassigned_amr_data_feed_reading.reload
        expect(unassigned_amr_data_feed_reading.meter).to eq(meter)
      end

      it 'removes the meter from associated amr_data_feed_readings' do
        described_class.new(meter).process_mpan_mpnr_change!
        existing_amr_data_feed_reading.reload
        expect(existing_amr_data_feed_reading.meter).to be_nil
      end

      it 'removes amr_validated_readings associated with the meter' do
        described_class.new(meter).process_mpan_mpnr_change!
        expect(AmrValidatedReading.where(id: existing_amr_validated_reading.id)).to be_empty
      end
    end
  end

  describe 'delete_meter!' do
    context 'when a meter is to be deleted with amr validated readings' do
      let!(:existing_amr_data_feed_reading) do
        create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log, meter: meter)
      end
      let!(:existing_amr_validated_reading) { create(:amr_validated_reading, meter: meter) }

      it 'removes the meter from associated amr_data_feed_readings' do
        described_class.new(meter).delete_meter!
        existing_amr_data_feed_reading.reload
        expect(existing_amr_data_feed_reading.meter).to be_nil
      end

      it 'removes amr_validated_readings associated with the meter' do
        described_class.new(meter).delete_meter!
        expect(AmrValidatedReading.where(id: existing_amr_validated_reading.id)).to be_empty
      end

      it 'deletes the meter' do
        expect { described_class.new(meter).delete_meter! }.to change(Meter, :count).from(1).to(0)
      end
    end

    context 'when a meter is to be deleted with no readings' do
      it 'deletes the meter' do
        expect { described_class.new(meter).delete_meter! }.to change(Meter, :count).from(1).to(0)
      end
    end
  end

  describe 'activate or deactivate' do
    context 'with a non-DCC meter' do
      let(:meter) { create(:electricity_meter) }

      it 'sets meter active' do
        meter.update(active: false)
        described_class.new(meter).activate_meter!
        expect(meter.active).to be_truthy
      end

      it 'sets meter inactive' do
        meter.update(active: true)
        described_class.new(meter).deactivate_meter!
        expect(meter.active).to be_falsey
      end

      it 'broadcasts activation event' do
        meter.update(active: false)
        expect { described_class.new(meter).activate_meter! }.to broadcast(:meter_activated, meter)
      end

      it 'broadcasts deactivation event' do
        meter.update(active: true)
        expect { described_class.new(meter).deactivate_meter! }.to broadcast(:meter_deactivated, meter)
      end
    end

    context 'with for DCC meter' do
      let!(:meter) { create(:electricity_meter_with_reading, dcc_meter: :smets2) }
      let!(:consents) do
        consents = instance_double(Meters::DccGrantTrustedConsents)
        allow(consents).to receive(:perform).and_return(true)
        allow(Meters::DccGrantTrustedConsents).to receive(:new).and_return(consents)
        consents
      end

      it 'sets meter active and consents' do
        meter.update(active: true, consent_granted: false, meter_review: create(:meter_review))
        described_class.new(meter).activate_meter!
        meter.reload
        expect(meter.active).to be true
        expect(consents).to have_received(:perform)
      end

      it 'sets meter inactive' do
        meter.update(active: true, consent_granted: true)
        described_class.new(meter).deactivate_meter!
        meter.reload
        expect(meter.active).to be_falsey
        expect(meter.consent_granted).to be_truthy
        expect(consents).not_to have_received(:perform)
      end

      it 'removes amr data feed readings' do
        described_class.new(meter).remove_data!
        expect(meter.amr_data_feed_readings.count).to eq 0
      end

      context 'when meter has validated readings' do
        let!(:meter) { create(:electricity_meter_with_validated_reading, dcc_meter: :smets2, consent_granted: true) }
        let!(:consents) do
          consents = instance_double(Meters::DccWithdrawTrustedConsents)
          allow(consents).to receive(:perform).and_return(true)
          allow(Meters::DccWithdrawTrustedConsents).to receive(:new).and_return(consents)
          consents
        end

        it 'removes validated readings' do
          described_class.new(meter).remove_data!
          expect(meter.amr_validated_readings.count).to eq 0
          expect(consents).to have_received(:perform)
        end
      end
    end
  end
end
