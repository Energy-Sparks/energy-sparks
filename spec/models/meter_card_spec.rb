require 'rails_helper'

describe MeterCard do

  let(:school){ create(:school) }

  it 'has no readings or values if the school has no readings' do
    meter_card = MeterCard.create(school: school, supply: :gas)
    expect(meter_card).to_not have_readings
  end

  it 'has readings if the school has validated readings for the supply' do
    meter = create :gas_meter_with_validated_reading, school: school
    meter_card = MeterCard.create(school: school, supply: :gas)
    expect(meter_card).to have_readings
  end

  it 'populates the last reading date' do
    meter = create :gas_meter_with_validated_reading, school: school
    meter_card = MeterCard.create(school: school, supply: :gas)
    expect(meter_card.values.latest_reading_date).to eq(Date.yesterday)
  end

  it 'calulates the first window day from the latest_reading_date' do
    meter = create :gas_meter_with_validated_reading, school: school
    meter_card = MeterCard.create(school: school, supply: :gas, window: 7)
    expect(meter_card.values.window_first_date).to eq(8.days.ago.to_date)
  end

  it 'populates the most usage date' do
    meter = create :gas_meter_with_validated_reading, school: school
    meter_card = MeterCard.create(school: school, supply: :gas, window: 7)
    expect(meter_card.values.most_usage).to eq(1.day.ago.to_date)
  end

  it 'populates the average usage' do
    meter = create :gas_meter_with_validated_reading, school: school
    meter_card = MeterCard.create(school: school, supply: :gas, window: 7)
    expect(meter_card.values.average_usage).to eq(19)
  end

  it 'returns no values if something goes awry within the calculations' do
    meter = create :gas_meter_with_validated_reading, school: school
    meter.amr_validated_readings.first.update(one_day_kwh: BigDecimal.new('NaN'))
    meter_card = MeterCard.create(school: school, supply: :gas, window: 7)
    expect(meter_card).to_not eq(19)
  end

end
