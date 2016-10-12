require 'rails_helper'

describe 'Meter' do

  it "should find latest reading" do

    reading = create(:meter_reading)
    meter = reading.meter

    expect( meter.latest_reading ).to eql(reading)

    today = create(:meter_reading, meter: meter, read_at: Date.today)
    create(:meter_reading, meter: meter, read_at: Date.today - 2.days)

    expect( meter.latest_reading ).to eql(today)

  end

  it "should find last imported" do
    reading = create(:meter_reading)
    meter = reading.meter

    expect( meter.last_read ).to eql(reading.read_at)

  end

end