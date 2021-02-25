require 'rails_helper'

describe MeterManagement do

  let!(:meter) { create(:electricity_meter) }
  let(:config) { create(:amr_data_feed_config) }
  let(:log) { create(:amr_data_feed_import_log) }

  describe 'process_creation!' do

    let!(:amr_data_feed_reading){ create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log, mpan_mprn: meter.mpan_mprn, meter: nil) }

    it 'assigns amr_data_feed_readings to the meter' do
      MeterManagement.new(meter).process_creation!
      expect(meter.amr_data_feed_readings).to match_array([amr_data_feed_reading])
    end

  end

  describe 'process_mpan_mpnr_change!' do

    let!(:existing_amr_data_feed_reading){ create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log, meter: meter) }
    let!(:existing_amr_validated_reading){ create(:amr_validated_reading, meter: meter) }

    let!(:unassigned_amr_data_feed_reading){ create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log, mpan_mprn: meter.mpan_mprn, meter: nil) }

    context 'if the mpan_mprn has changed' do
      it 'assigns amr_data_feed_readings to the meter using the new mpan_mprn' do
        MeterManagement.new(meter).process_mpan_mpnr_change!
        unassigned_amr_data_feed_reading.reload
        expect(unassigned_amr_data_feed_reading.meter).to eq(meter)
      end

      it 'removes the meter from associated amr_data_feed_readings' do
        MeterManagement.new(meter).process_mpan_mpnr_change!
        existing_amr_data_feed_reading.reload
        expect(existing_amr_data_feed_reading.meter).to be_nil
      end

      it 'removes amr_validated_readings associated with the meter' do
        MeterManagement.new(meter).process_mpan_mpnr_change!
        expect(AmrValidatedReading.where(id: existing_amr_validated_reading.id)).to be_empty
      end
    end

  end

  describe 'delete_meter!' do
    context 'if a meter is to be deleted with amr validated readings' do
      let!(:existing_amr_data_feed_reading){ create(:amr_data_feed_reading, amr_data_feed_config: config, amr_data_feed_import_log: log, meter: meter) }
      let!(:existing_amr_validated_reading){ create(:amr_validated_reading, meter: meter) }

      it 'removes the meter from associated amr_data_feed_readings' do
        MeterManagement.new(meter).delete_meter!
        existing_amr_data_feed_reading.reload
        expect(existing_amr_data_feed_reading.meter).to be_nil
      end

      it 'removes amr_validated_readings associated with the meter' do
        MeterManagement.new(meter).delete_meter!
        expect(AmrValidatedReading.where(id: existing_amr_validated_reading.id)).to be_empty
      end

      it 'deletes the meter' do
        expect { MeterManagement.new(meter).delete_meter! }.to change { Meter.count }.from(1).to(0)
      end
    end

    context 'if a meter is to be deleted with no readings' do
      it 'deletes the meter' do
        expect { MeterManagement.new(meter).delete_meter! }.to change { Meter.count }.from(1).to(0)
      end
    end
  end

  describe 'valid_dcc_meter?' do
    let(:n3rgy_api)         { double(:n3rgy_api) }
    let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }

    it "validates registered dcc meters" do
      meter = create(:electricity_meter, dcc_meter: true, consent_granted: true)
      expect(n3rgy_api).to receive(:status).with(meter.mpan_mprn) do
        :available
      end
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).valid_dcc_meter? ).to eql(true)
    end

    it "validates registered and consented dcc meters" do
      meter = create(:electricity_meter, dcc_meter: true, consent_granted: true)
      expect(n3rgy_api).to receive(:status).with(meter.mpan_mprn) do
        :consent_required
      end
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).valid_dcc_meter? ).to eql(true)
    end

    it "does not validate unregistered dcc meters" do
      meter = create(:electricity_meter, dcc_meter: true, consent_granted: true)
      expect(n3rgy_api).to receive(:status).with(meter.mpan_mprn) do
        :unknown
      end
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).valid_dcc_meter? ).to eql(false)
    end

    it "validates all other meters" do
      meter = create(:electricity_meter)
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).valid_dcc_meter? ).to eql false
      meter = create(:gas_meter)
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).valid_dcc_meter? ).to eql false
    end

    it "handles API errors" do
      meter = create(:electricity_meter, dcc_meter: true, consent_granted: true)
      allow(n3rgy_api).to receive(:status).with(meter.mpan_mprn) do
        raise
      end
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).check_n3rgy_status ).to eql(:api_error)
      expect( MeterManagement.new(meter, n3rgy_api_factory: n3rgy_api_factory).valid_dcc_meter? ).to eql(false)
    end
  end

end
