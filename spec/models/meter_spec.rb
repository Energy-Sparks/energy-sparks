require 'rails_helper'

describe 'Meter', :meters do

  describe 'valid?' do
    describe 'mpan_mprn' do
      context 'with an electricity meter' do

        let(:attributes) {attributes_for(:electricity_meter)}

        it 'is valid with a 13 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'validates the distributor id' do
          meter = Meter.new(attributes.merge(mpan_mprn: 9998598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end
      end

      context 'with a gas meter' do
        let(:attributes) {attributes_for(:gas_meter)}

        it 'is valid with a 10 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number longer than 10 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 8758348459567832))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end
    end
  end

  describe 'correct_mpan_check_digit?' do
    it 'returns true if the check digit matches' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns false if the check digit does not match' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end

    it 'returns false if the mpan is short' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end
  end

  describe '#last_reading' do
    it "should find latest reading" do
      reading = create(:amr_data_feed_reading)
      meter = reading.meter

      expect(meter.last_read).to eql(reading.reading_date)

      today = create(:amr_data_feed_reading, meter: meter, reading_date: Date.today)
      create(:amr_data_feed_reading, meter: meter, reading_date: Date.today - 2.days)

      expect(meter.last_read).to eql(today.reading_date)
    end
  end

  describe '#last_read' do
    it "should find last imported" do
      reading = create(:amr_data_feed_reading)
      meter = reading.meter

      expect(meter.last_read).to eql(reading.reading_date)
    end
  end

  describe '#safe_destroy' do

    it 'does not let you delete if there is an assoicated meter reading' do
      meter = create(:electricity_meter)
      create(:amr_data_feed_reading, meter: meter)

      expect{
        meter.safe_destroy
      }.to raise_error(EnergySparks::SafeDestroyError, 'Meter has associated readings')
    end

    it 'does not let you delete if there is an assoicated AMR meter reading' do
      meter = create(:electricity_meter)
      # TODO: find a better way of generating this record?
      meter.amr_data_feed_readings.create!(
        mpan_mprn: meter.mpan_mprn,
        reading_date: Date.today,
        readings: ["1.0"] * 48
      )

      expect{
        meter.safe_destroy
      }.to raise_error(EnergySparks::SafeDestroyError, 'Meter has associated readings')
    end

    it 'lets you delete if there are no meter readings' do
      meter = create(:electricity_meter)

      expect{
        meter.safe_destroy
      }.to change{Meter.count}.from(1).to(0)
    end

  end
end
