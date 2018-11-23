require 'rails_helper'

describe MeterManagement do

  let(:meter){ create(:electricity_meter) }

  describe 'process_creation!' do

    let!(:amr_data_feed_reading){ create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, meter: nil) }

    it 'assigns amr_data_feed_readings to the meter' do
      MeterManagement.new(meter).process_creation!
      expect(meter.amr_data_feed_readings).to match_array([amr_data_feed_reading])
    end

  end

  describe 'process_mpan_mpnr_change!' do

    let!(:existing_amr_data_feed_reading){ create(:amr_data_feed_reading, meter: meter) }
    let!(:existing_amr_validated_reading){ create(:amr_validated_reading, meter: meter) }

    let!(:unassigned_amr_data_feed_reading){ create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, meter: nil) }

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

end
