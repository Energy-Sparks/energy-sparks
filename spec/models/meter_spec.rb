require 'rails_helper'

describe 'Meter', :meters do
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
      meter = create(:meter)
      create(:amr_data_feed_reading, meter: meter)

      expect{
        meter.safe_destroy
      }.to raise_error(EnergySparks::SafeDestroyError, 'Meter has associated readings')
    end

    it 'does not let you delete if there is an assoicated AMR meter reading' do
      meter = create(:meter)
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
      meter = create(:meter)

      expect{
        meter.safe_destroy
      }.to change{Meter.count}.from(1).to(0)
    end

  end
end
