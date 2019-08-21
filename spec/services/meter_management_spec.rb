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
end
